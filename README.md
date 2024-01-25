# `apt-packages-exporter`

Simple Python3 script what generates textfile metrics from APT package states on every `apt update` or `dpkg` invocation for `node_exporter`'s textfile collector.

## Dependencies

Script should be installed as `.deb` package for `python3-apt` dependency to be present. May not work if you change path to your `python3` binary (e.g. using `update-alternatives` to point to self-compiled Python).

## Installation and usage

1. Install package or place `apt_packages_exporter` file somwhere in `PATH` (default location is `/usr/bin/`)

2. If installing manually, install dependencies: `apt updage && apt install -y --no-install-recommends python3-apt python3-prometheus-client`

3. Create APT hook (default path is `/etc/apt/apt.conf.d/50metrics`):

```plain
APT::Update::Post-Invoke-Success {"/usr/bin/apt_packages_exporter"};
DPkg::Post-Invoke {"/usr/bin/apt_packages_exporter"};
```

4. If you want to change default textfile metrics location (`/var/lib/node_exporter/textfile_collector`), add `--dir` argument:

```plain
APT::Update::Post-Invoke-Success {"/usr/bin/apt_packages_exporter --dir /var/lib/node_exporter/textfile_collector"};
DPkg::Post-Invoke {"/usr/bin/apt_packages_exporter --dir /var/lib/node_exporter/textfile_collector"};
```

5. Configure `node_exporter` to enable textfile collector: add `--collector.textfile.directory /var/lib/node_exporter/textfile_collector` argument

6. Setup periodic `apt update` job — on modern Ubuntu and Debian systems this is handled out of the box with `unattended-upgrades` package and systemd's `apt-daily.timer` unit.

## Metrics and labels

### Metrics

| Name                     | Type  | Labels                                                                                         | Description                                                                            |
|--------------------------|-------|------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `apt_reboot_required`    | Gauge |                                                                                                | If set to 1, `/run/reboot-required` flag file is found (usually after kernel upgrades) |
| `apt_packages_installed` | Gauge | `archive`, `component`, `label`, `origin`, `codename`, `site`, `automatic`, `trusted`, `state` | Amount of packages installed and in which state                                        |
| `apt_packages_marked`    | Gauge | `archive`, `component`, `label`, `origin`, `codename`, `site`, `automatic`, `trusted`, `mark`  | Amount of packages marked and how                                                      |

### Labels

Examples are for Ubuntu 20.04 with PostgreSQL repository added.

| Name        | Description                        | Example                                                                                    |
|-------------|------------------------------------|--------------------------------------------------------------------------------------------|
| `archive`   | APT origin archive                 | `focal` or `focal-pgdg`                                                                    |
| `component` | APT origin component               | `main`                                                                                     |
| `label`     | APT origin label                   | `Ubuntu`  or `PostgreSQL for Debian/Ubuntu repository`                                     |
| `origin`    | APT origin origin                  | `Ubuntu` or `apt.postgresql.org`                                                           |
| `codename`  | APT origin codename                | `focal` or `focal-pgdg`                                                                    |
| `site`      | APT origin site                    | `archive.ubuntu.com` or `apt.postgresql.org`                                               |
| `automatic` | Package is installed automatically | `true` or `false`                                                                          |
| `trusted`   | APT origin is trusted              | `true` or `false`                                                                          |
| `state`     | Current APT package states count   | `installed`, `auto_installed`, `auto_removable`, `inst_broken`, `now_broken`, `upgradable` |
| `mark`      | Curremt APT package marks count    | `delete`, `downgrade`, `install`, `keep`, `reinstall`, `upgrade`                           |

Note what `installed` packages count is total count of packages which may be simultaneusly in different states (e.g. `upgradable` and `auto_removable`).

If package has more than one installation candidate with same priority, only first counts.

## Linting and building

To build own package, simply run `make` command in project directory. Only `dpkg-deb` and `gzip` packages are needed.

To lint script and package with `make lint`, you will need `pylint` (`python3 -m pip install pylint`) and `lintian` (`apt install -y lintian`) tools.
