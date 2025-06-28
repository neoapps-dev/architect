[[ " $* " == *" --help "* ]] && help && exit
[[ " $* " == *" --version "* ]] && version && exit
[[ " $* " == *" --validate "* ]] && validate_config && exit
[[ " $* " == *" --make-config "* ]] && generate_config && exit
[[ " $* " == *" --diff "* ]] && diff && exit
[[ " $* " == *" --apply-diff "* ]] && apply_diff && exit
[[ " $* " == *" --list-snapshots "* ]] && list_snapshots && exit
[[ " $* " == *" --take-snapshot-now "* ]] && take_snapshot_now && exit
[[ " $* " == *" --rollback "* ]] && rollback && exit
[[ " $* " == *" --install-aur-only "* ]] && install_aur && exit
[[ " $* " == *" --dotfiles-sync "* ]] && sync_dotfiles "$2" && exit
[[ " $* " == *" --dotfiles-status "* ]] && status_dotfiles "$2" && exit
[[ " $* " == *" --dotfiles-edit "* ]] && edit_dotfile "$2" "$3" && exit
[[ " $* " == *" --pacstrap "* ]] && pacstrapper "$2" "$3" && exit
[[ " $* " == *" --purge-all-snapshots "* ]] && purge_all_snapshots && exit
[[ " $* " == *" --purge-snapshots "* ]] && purge_snapshots "$2" && exit
[[ " $* " == *" --test "* ]] && run_test && exit
remove_packages
install_packages
post_install
