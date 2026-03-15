import os
import sys
import glob
import time
import json
import torch
import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from transformers import AutoTokenizer, AutoModel
import uvicorn
from watchfiles import awatch
import asyncio

# The Holocron: A Codebase RAG System

# CONFIGURATION
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
PORT = 6666 # Order 66 ;)

app = FastAPI()
tokenizer = None
model = None
index = {} # Map path -> vector
code_content = {} # Map path -> content

class Query(BaseModel):
    query: str
    top_k: int = 5

class Result(BaseModel):
    path: str
    content: str
    score: float

def load_model():
    global tokenizer, model
    print(f"Loading model {MODEL_NAME}...")
    try:
        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        model = AutoModel.from_pretrained(MODEL_NAME)
        model.eval()
        print("Model loaded.")
    except Exception as e:
        print(f"Failed to load model: {e}")
        sys.exit(1)

def embed(text_list):
    if not text_list: return []
    inputs = tokenizer(text_list, padding=True, truncation=True, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
    # Mean pooling
    embeddings = outputs.last_hidden_state.mean(dim=1)
    return embeddings.numpy()

def index_file(path):
    try:
        # Skip if directory
        if os.path.isdir(path): return

        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        if not content.strip(): return
        
        # Embed first 2000 chars as a rough summary
        vec = embed([content[:2000]])[0]
        
        index[path] = vec.tolist()
        code_content[path] = content
        # print(f"Indexed: {path}") # Reduce log spam
    except Exception as e:
        # print(f"Failed to index {path}: {e}")
        pass

async def build_index(root_dir="."):
    print(f"Scanning {root_dir}...")
    files = glob.glob(f"{root_dir}/**/*", recursive=True)
    valid_extensions = {'.py', '.js', '.ts', '.tsx', '.jsx', '.go', '.rs', '.c', '.cpp', '.h', '.java', '.md', '.sh', '.json', '.html', '.css'}
    
    count = 0
    total = 0
    for f in files:
        if os.path.isfile(f) and os.path.splitext(f)[1] in valid_extensions:
            if "node_modules" in f or ".git" in f or "venv" in f or "__pycache__" in f: continue
            index_file(f)
            count += 1
            if count % 20 == 0: await asyncio.sleep(0.01) # Yield
    print(f"Index built. {count} files indexed.")

@app.on_event("startup")
async def startup_event():
    load_model()
    asyncio.create_task(build_index())
    asyncio.create_task(watcher())

async def watcher():
    print("Starting watcher...")
    # watch current dir
    async for changes in awatch('.', recursive=True):
        for change, path in changes:
            # 1=added, 2=modified, 3=deleted
            try:
                if change in [1, 2]:
                    if "node_modules" in path or ".git" in path: continue
                    index_file(path)
                    print(f"Updated: {path}")
                elif change == 3:
                    if path in index:
                        del index[path]
                        del code_content[path]
                        print(f"Deleted: {path}")
            except Exception as e:
                print(f"Watcher error: {e}")

@app.post("/query", response_model=List[Result])
async def search(q: Query):
    if not index:
        return []
    
    try:
        query_vec = embed([q.query])[0]
        
        paths = list(index.keys())
        matrix = np.array([index[p] for p in paths])
        
        norm_q = np.linalg.norm(query_vec)
        if norm_q > 0: query_vec = query_vec / norm_q
        
        norms = np.linalg.norm(matrix, axis=1, keepdims=True)
        norms[norms == 0] = 1 # avoid div by zero
        matrix = matrix / norms
        
        scores = np.dot(matrix, query_vec)
        
        top_indices = np.argsort(scores)[::-1][:q.top_k]
        
        results = []
        for idx in top_indices:
            p = paths[idx]
            score = float(scores[idx])
            results.append(Result(path=p, content=code_content[p][:1000], score=score))
            
        return results
    except Exception as e:
        print(f"Search error: {e}")
        return []

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=PORT)
