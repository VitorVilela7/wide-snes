LUIGI_GRAPHICS_URL = https://dl.smwcentral.net/26117/sepluigi_23_sa1.zip
ORIGINAL_ROM = smw.sfc

RUN = docker run \
		--interactive \
		--tty \
		--rm \
		--mount "type=bind,src=$$(pwd),dst=/project" \
		--workdir /project \
		--user "$$(id -u):$$(id -g)" \
		m00qek/snes-game-patcher:latest

prepare:
	@rm -rf ./build
	@mkdir -p ./build/resources
	@mkdir -p ./build/downloaded

	@$(RUN) curl $(LUIGI_GRAPHICS_URL) \
		--output ./build/downloaded/luigi.zip
	@$(RUN) unzip ./build/downloaded/luigi.zip -d ./build/downloaded
	@cp ./build/downloaded/sepluigi_23_sa1/*.bin ./build/resources

	@curl -X POST https://content.dropboxapi.com/2/files/download \
		--header "Authorization: Bearer $(DROPBOX_TOKEN)" \
		--header "Dropbox-API-Arg: {\"path\": \"/$(ORIGINAL_ROM)\"}" \
		--output ./build/resources/smw.sfc

rom:
	@echo 'Assembling hacked ROM...'
	@rm -rf ./build/release
	@mkdir -p ./build/release
	@cp ./build/resources/*.sfc ./build/release/smw.sfc
	@$(RUN) asar \
		--define mario_bin='../build/resources/Mario.bin' \
		--define luigi_bin='../build/resources/Luigi.bin' \
		./src/main.asm \
		./build/release/smw.sfc
	@echo 'Done!'

patch: rom
	@echo 'Creating patch with differences between original and hacked ROM...'
	@$(RUN) flips \
		--create \
		--bps-delta \
		./build/resources/smw.sfc \
		./build/release/smw.sfc \
		./build/release/smw.bps

watch:
	@echo 'Assembling the hacked ROM when any file on "src/" changes...'
	@echo
	@$(RUN) bash -c 'find src/ | entr make RUN="" rom'
