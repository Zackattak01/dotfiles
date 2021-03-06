#disable 'fish is an interactive shell blah blah blah ....'
set fish_greeting
eval (ssh-agent -c) >/dev/null 2>&1

# startx
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
	set PATH "/home/zack/.cargo/bin/:/home/zack/.local/bin:/home/zack/dotnet:$PATH"
	#set-env-vars 
	exec startx -- -keeptty
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

function set-env-vars
	if test -e $HOME/.config/fish/private-env-vars.fish
		source $HOME/.config/fish/private-env-vars.fish
	else
		echo "[WARN] 'private-env-vars.fish' is not present!  Your env vars wont be set until it is!"
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

neofetch
set-env-vars


alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias monoff='xset dpms force off'
alias vim='nvim'

starship init fish | source
