# history management
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT='%F %T '
HISTFILE=~/.bash_history_ansible

function _ansible_inventory {
  ansible-inventory --list 2>/dev/null | jq -r "keys | .[]" > /tmp/.inventory
  ansible-inventory --list 2>/dev/null | jq -r ".[].hosts | .[]?" >> /tmp/.inventory
}

function _ansible_inventory_completion {
  COMPREPLY=()
  cur=$(_get_cword)

  while IFS= read -r target; do
    COMPREPLY+=( "$target" )
  done < <(fzf -f "$cur" < /tmp/.inventory)
  return 0
}

alias ll='ls -la'
alias a='ansible'
alias a-fcts='ansible -m setup'
alias a-sh='ansible -m shell -a'
alias a-tags='ansible-playbook --list-tags'
alias a-vars='ansible-inventory --host'
alias ap='ansible-playbook -D'
alias ap-chk='ansible-playbook -C -D'
PS1='\[\e[0;33m\]\h\[\e[m\]:\w [\[\e[0;32m\]$(git rev-parse --abbrev-ref HEAD)\[\e[m\]]$ '

complete -F _ansible_inventory_completion a a-fcts a-sh a-vars ansible
