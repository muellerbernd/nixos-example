HOSTNAME = $(shell hostname)

ifndef HOSTNAME
	$(error Hostname unknown)
endif

switch:
	nixos-rebuild switch --use-remote-sudo --flake .#${HOSTNAME} -L --show-trace

boot:
	nixos-rebuild boot --use-remote-sudo --flake .#${HOSTNAME} -L

test:
	nixos-rebuild test --use-remote-sudo --flake .#${HOSTNAME} -L

vm:
	nixos-rebuild build-vm --flake .#${HOSTNAME}

update:
	nix flake update

upgrade:
	make update && make switch
