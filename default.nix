# FIXME text bbox positions are wrong in the PDF file
# all bboxes are packed in the top-left corner

# TODO dont depend on local LLM server
# also offer a standalone tool like
# https://github.com/BartWojtowicz/videopython

# TODO test FastAPI web server: pdf_ocr.server

{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "local-llm-pdf-ocr";
  version = "0-unstable-2026-04-28-b160c4a";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ahnafnafee";
    repo = "local-llm-pdf-ocr";
    # https://github.com/ahnafnafee/local-llm-pdf-ocr/pull/5
    rev = "676202cc627e3f45050236f138230c34b78465f2";
    hash = "sha256-klMcv9L5FF8hWYni//341sDZdzd1hzCaIkCw3uXSQ6w=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/>=.*",$/",/' pyproject.toml

    # fix: ModuleNotFoundError: No module named 'src'
    grep -r -l -F " src.pdf_ocr" . |
    grep '\.py$' |
    xargs sed -i 's/ src\.pdf_ocr/ pdf_ocr/'

    # move scripts to package
    mv -t src/pdf_ocr main.py server.py static scripts tests

    # add main script
    # install server assets
    cat >>pyproject.toml <<EOF
    [project.scripts]
    local-llm-pdf-ocr = "pdf_ocr.main:main"

    [tool.setuptools]
    include-package-data = true

    [tool.setuptools.package-data]
    pdf_ocr = ["static/*"]
    EOF

    # fix: print errors
    substituteInPlace src/pdf_ocr/main.py \
      --replace \
        "    except Exception:" \
        "$(
          echo "    except Exception as exc:"
          echo "        raise"
        )"

    sed -i '/^import pillow_avif.*/d' src/pdf_ocr/core/pdf.py
    sed -i '/.*pillow-avif-plugin.*/d' pyproject.toml
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    fastapi
    openai
    opencv-python-headless
    pillow
    # error: 'pillow-avif-plugin' has been removed because 'pillow' has native avif support since 11.3
    # pillow-avif-plugin
    pymupdf
    python-dotenv
    python-multipart
    rich
    surya-ocr
    torch
    torchvision
    tqdm
    uvicorn
    websockets
  ];

  pythonImportsCheck = [
    "pdf_ocr"
  ];

  # doCheck = false;
  dontUsePytestCheck = true;

  meta = {
    description = "Convert scanned PDFs into searchable text locally using Vision LLMs (olmOCR). 100% private, offline, and free. Features a modern Web UI & CLI";
    homepage = "https://github.com/ahnafnafee/local-llm-pdf-ocr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "local-llm-pdf-ocr";
  };
})
