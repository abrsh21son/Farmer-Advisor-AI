# Evaluation Dataset

questions.jsonl contains hand-curated question-answer pairs used to benchmark
the RAG pipeline retrieval precision and answer quality.

## Format
Each line is a JSON object:
{"id": "q001", "question": "When is teff planted?", "crop": "teff"}

## Running Evaluation
python scripts/evaluate.py --dataset evaluation/questions.jsonl