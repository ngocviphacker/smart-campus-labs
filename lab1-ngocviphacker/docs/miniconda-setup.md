# Thiết lập Python bằng Miniconda

Sinh viên có thể dùng Miniconda thay cho `venv`. Khuyến nghị tạo môi trường riêng cho học phần.

## 1. Tạo môi trường

```bash
conda create -n api-platform python=3.11 -y
conda activate api-platform
python -m pip install --upgrade pip
```

## 2. Cài thư viện Python

```bash
pip install -r requirements.txt
```

Hoặc dùng file `environment.yml`:

```bash
conda env create -f environment.yml
conda activate api-platform
```

## 3. Kiểm tra

```bash
python --version
python -c "import fastapi, pydantic, httpx, numpy; print('Python env OK')"
```

## 4. Lưu ý

Không cài trực tiếp vào Python hệ thống. Luôn dùng môi trường riêng:

```bash
conda activate api-platform
```
