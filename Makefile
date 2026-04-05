all: pot update-po build

build: schemas
	mkdir -p "./dist"
	gnome-extensions pack \
		--force \
		--extra-source=ui \
		--extra-source=convenienceExt.js \
		--extra-source=conveniencePref.js \
		--extra-source=indicator.js \
		--extra-source=shortcut.js \
		./display-brightness-ddcutil@john.local/ \
		--out-dir=./dist

install:
	gnome-extensions install \
		--force \
		"./dist/display-brightness-ddcutil@john.local.shell-extension.zip"

pot:
	mkdir -p "./display-brightness-ddcutil@john.local/po"
	xgettext \
		--from-code=UTF-8 \
		--output="./display-brightness-ddcutil@john.local/po/display-brightness-ddcutil.pot" \
		"./display-brightness-ddcutil@john.local/ui/"* \
		"./display-brightness-ddcutil@john.local/extension.js" \
		"./display-brightness-ddcutil@john.local/shortcut.js"

update-po:
	for po_file in "./display-brightness-ddcutil@john.local/po/"*.po; do \
		msgmerge --update "$$po_file" "display-brightness-ddcutil@john.local/po/display-brightness-ddcutil.pot"; \
	done

schemas:
	glib-compile-schemas ./display-brightness-ddcutil@john.local/schemas

clean:
	rm -f "./dist/display-brightness-ddcutil@john.local.shell-extension.zip"
	rm -f "./display-brightness-ddcutil@john.local/schemas/gschemas.compiled"
