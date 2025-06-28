SRC_DIR := src
OUT := architect
INSTALL_DIR := /usr/bin
all: build
build:
	@echo "[*] Building $(OUT)..."
	@cp $(SRC_DIR)/main.sh $(OUT)
	@for f in $(shell find $(SRC_DIR) -type f -name '*.sh' ! -name 'main.sh' | sort); do \
		echo "[+] Merging $$f"; \
		echo "" >> $(OUT); \
		cat $$f >> $(OUT); \
	done
	@chmod +x $(OUT)
	@echo "[+] Built $(OUT)"

clean:
	@echo "[*] Cleaning..."
	@rm -f $(OUT)
	@echo "[+] Cleaned"

install: build
	@echo "[*] Installing to $(INSTALL_DIR)/$(OUT)..."
	@sudo cp $(OUT) $(INSTALL_DIR)/$(OUT)
	@echo "[+] Installed to $(INSTALL_DIR)/$(OUT)"
