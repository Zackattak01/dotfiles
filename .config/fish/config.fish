#disable 'fish is an interactive shell blah blah blah ....'
set fish_greeting

fish_vi_key_bindings

# startx
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    #set PATH "/home/zack/.cargo/bin/:/home/zack/.local/bin:/home/zack/dotnet:/home/zack/.dotnet/tools:$PATH"
    #set PATH $PATH:$GOPATH/bin
	#set-env-vars 
    eval (ssh-agent -c) >/dev/null 2>&1
    exec startx -- -keeptty
    #exec Hyprland
    end
end

function ex --description "Expand or extract bundled & compressed files"
  set --local ext (echo $argv[1] | awk -F. '{print $NF}')
  switch $ext
    case tar  # non-compressed, just bundled
      tar -xvf $argv[1]
    case gz
      if test (echo $argv[1] | awk -F. '{print $(NF-1)}') = tar  # tar bundle compressed with gzip
        tar -zxvf $argv[1]
      else  # single gzip
        gunzip $argv[1]
      end
    case tgz  # same as tar.gz
      tar -zxvf $argv[1]
    case bz2  # tar compressed with bzip2
      tar -jxvf $argv[1]
    case rar
      unrar x $argv[1]
    case zip
      unzip $argv[1]
    case '*'
      echo "unknown extension"
  end
end

function new-csharp-sln
	set --local name $argv[1]
	mkdir -p $HOME/repos/csharp/$name
	cd $HOME/repos/csharp/$name
	dotnet new sln
	dotnet new gitignore
end

function new-csharp-classlib
	set --local name $argv[1]

	set --local files *.sln
        if not set -q files[1]
		new-csharp-sln $name
        end

	mkdir $name
	cd $name
	dotnet new classlib
	cd ..
	dotnet sln add $name
end

function new-csharp-console
	set --local name $argv[1]

	set --local files *.sln
        if not set -q files[1]
		new-csharp-sln $name
        end

	mkdir $name
	cd $name
	dotnet new console
	cd ..
	dotnet sln add $name
end

function aw-theme
	vim ~/.config/awesome/themes/comfy/theme.lua
end

function aw-rc
	vim ~/.config/awesome/rc.lua
end

# dont display neofetch if the terminal is being run in vim tmux, or jetbrains
if not set -q VIMRUNTIME; and not set -q TMUX; and test "$TERMINAL_EMULATOR" != "JetBrains-JediTerm"
    fastfetch
end
set -x BROWSER firefox
set -x EDITOR nvim
set XDG_CONFIG_HOME /home/zack 
set GOPATH $HOME/go
source ~/.config/fish/variables.fish


alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias monoff='xset dpms force off'
alias vim='nvim'

zoxide init --cmd cd fish | source

starship init fish | source
