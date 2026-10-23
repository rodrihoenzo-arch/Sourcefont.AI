FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    nodejs \
    tesseract-ocr \
    tesseract-ocr-por \
    tesseract-ocr-eng \
    fonts-dejavu-core \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 appuser

WORKDIR /app

COPY . /tmp/repo/
RUN python3 -c "import zipfile, shutil, pathlib, re; src=pathlib.Path('/tmp/repo'); dst=pathlib.Path('/app'); zfiles=list(src.glob('*.zip')); zipfile.ZipFile(max(zfiles, key=lambda x: (int(m.group(1)) if (m:=re.search(r'\((\d+)\)', x.name)) else 0, x.stat().st_size))).extractall(dst) if zfiles else shutil.copytree(src, dst, dirs_exist_ok=True)" && rm -rf /tmp/repo

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

RUN mkdir -p /app/data/packs /app/data/dossiers && \
    chown -R appuser:appuser /app

USER appuser

ENV PORT=7860
ENV PYTHONUNBUFFERED=1

EXPOSE 7860

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-7860}"]
