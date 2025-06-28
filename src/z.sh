[[ " $* " == *" --help "* ]] && help
[[ " $* " == *" --version "* ]] && version
[[ " $* " == *" --validate "* ]] && validate_config
[[ " $* " == *" --make-config "* ]] && generate_config
[[ " $* " == *" --diff "* ]] && diff
[[ " $* " == *" --apply-diff "* ]] && apply_diff
[[ " $* " == *" --list-snapshots "* ]] && list_snapshots
[[ " $* " == *" --take-snapshot-now "* ]] && take_snapshot_now
[[ " $* " == *" --rollback "* ]] && rollback
[[ " $* " == *" --install-aur-only "* ]] && install_aur && exit
[[ " $* " == *" --dotfiles-sync "* ]] && sync_dotfiles "$2"
[[ " $* " == *" --dotfiles-status "* ]] && status_dotfiles "$2"
[[ " $* " == *" --dotfiles-edit "* ]] && edit_dotfile "$2" "$3"
[[ " $* " == *" --pacstrap "* ]] && pacstrapper "$2" "$3"
[[ " $* " == *" --purge-all-snapshots "* ]] && purge_all_snapshots
[[ " $* " == *" --purge-snapshots "* ]] && purge_snapshots "$2"
[[ " $* " == *" --test "* ]] && run_test
remove_packages
install_packages
post_install
