#!/bin/sh

src=2026-04-10.10-00.avif

for model in allenai_olmocr-2-7b-1025 qwen3-vl-8b-instruct; do
  read -p "load the '$model' model in lm-studio and hit enter to run local-llm-pdf-ocr"
  local-llm-pdf-ocr $src $src.default.$model.pdf "$@"
  local-llm-pdf-ocr $src $src.grounded.$model.pdf --grounded "$@"
done
