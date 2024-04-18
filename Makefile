.PHONY: lint-code check-deb lint clean
.INTERMEDIATE: changelog.gz apt-packages-exporter.1.gz

apt-packages-exporter_1.0-1_all.deb: pack
	mv deb.deb apt-packages-exporter_1.0-1_all.deb

pack:
	mkdir -p ./deb/usr/bin
	mkdir -p ./deb/etc/apt/apt.conf.d
	mkdir -p ./deb/usr/share/doc/apt-packages-exporter
	mkdir -p ./deb/usr/share/man/man1

	gzip --force --keep --best --no-name changelog apt-packages-exporter.1

	cp apt_packages_exporter ./deb/usr/bin/apt-packages-exporter
	cp 50metrics ./deb/etc/apt/apt.conf.d
	cp LICENSE ./deb/usr/share/doc/apt-packages-exporter/copyright

	mv changelog.gz ./deb/usr/share/doc/apt-packages-exporter/
	mv apt-packages-exporter.1.gz ./deb/usr/share/man/man1/

	dpkg-deb --root-owner-group --build ./deb

lint-code:
	pylint --score=n ./apt_packages_exporter

check-deb:
	lintian --pedantic --suppress-tags initial-upload-closes-no-bugs deb.deb

lint: lint-code pack check-deb

clean:
	rm -rf ./deb/etc ./deb/usr *.deb
