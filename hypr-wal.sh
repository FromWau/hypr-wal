#!/usr/bin/env bash

changeWallpaper() {
	monitors=(
		$(hyprctl monitors -j | jq -r '.[].name')
	)

    pics=()
    if ! command -v find-similar-pics &>/dev/null; then
        pics=(
            $(fd ".png|.jpg|.jpeg" ~/Pictures/wallpapers/ | shuf -n ${#monitors[@]})
        )
    else 
        rand_pic=$(fd ".png|.jpg|.jpeg" ~/Pictures/wallpapers/ | shuf -n 1)
        pics[0]=$rand_pic

        if [ ! ${#monitors[@]} -eq 1 ]; then
            similar_pics=(
                $(find-similar-pics "$rand_pic" ~/Pictures/wallpapers/ -s -n $(( ${#monitors[@]} - 1)))
            )

            pics+=( "${similar_pics[@]}" )
        fi
    fi   

	for i in "${!monitors[@]}"; do
		monitor=${monitors[$i]}
		pic=${pics[$i]}

		swww img -o "$monitor" "$pic" \
			--transition-step 255 \
			--transition-fps 60 \
			--transition-type=any \
			--transition-bezier .4,.04,.2,1
	done
}

updateCava() {
	cp -r "$HOME"/.cache/wal/colors-cava.cava "$HOME"/.config/cava/config &&
		cat <<EOF >>"$HOME"/.config/cava/config


[input]
method = pipewire
source = auto
EOF

	# refresh cava if running
	[[ $(pidof cava) != "" ]] && pkill -USR1 cava
}

updateNcspot() {
    if [[ $(rg "^\[theme\]\$" ~/.config/ncspot/config.toml) ]]; then

        # feels wrong but toml cant source other toml files

        # Extract the new hex values from colors-ncspot.toml
        # background=$(awk -F' = ' '/^background / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        primary=$(awk -F' = ' '/^primary / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        secondary=$(awk -F' = ' '/^secondary / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        title=$(awk -F' = ' '/^title / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        playing=$(awk -F' = ' '/^playing / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        playing_selected=$(awk -F' = ' '/^playing_selected/ {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        playing_bg=$(awk -F' = ' '/^playing_bg / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        highlight=$(awk -F' = ' '/^highlight / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        highlight_bg=$(awk -F' = ' '/^highlight_bg / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        error=$(awk -F' = ' '/^error / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        error_bg=$(awk -F' = ' '/^error_bg / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        statusbar=$(awk -F' = ' '/^statusbar / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        statusbar_progress=$(awk -F' = ' '/^statusbar_progress / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        statusbar_bg=$(awk -F' = ' '/^statusbar_bg / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        cmdline=$(awk -F' = ' '/^cmdline / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        cmdline_bg=$(awk -F' = ' '/^cmdline_bg / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")
        search_match=$(awk -F' = ' '/^search_match / {print $2}' "$HOME/.cache/wal/colors-ncspot.toml")

        # Replace the values in config.toml
        # sed -i 's/^background = .*/background = '$background'/' "$HOME"/.config/ncspot/config.toml # dont set because we like transparency
        sed -i 's/^primary = .*/primary = '"$primary"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^secondary = .*/secondary = '"$secondary"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^title = .*/title = '"$title"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^playing = .*/playing = '"$playing"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^playing_selected = .*/playing_selected = '"$playing_selected"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^playing_bg = .*/playing_bg = '"$playing_bg"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^highlight = .*/highlight = '"$highlight"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^highlight_bg = .*/highlight_bg = '"$highlight_bg"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^error = .*/error = '"$error"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^error_bg = .*/error_bg = '"$error_bg"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^statusbar = .*/statusbar = '"$statusbar"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^statusbar_progress = .*/statusbar_progress = '"$statusbar_progress"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^statusbar_bg = .*/statusbar_bg = '"$statusbar_bg"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^cmdline = .*/cmdline = '"$cmdline"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^cmdline_bg = .*/cmdline_bg = '"$cmdline_bg"'/' "$HOME"/.config/ncspot/config.toml
        sed -i 's/^search_match = .*/search_match = '"$search_match"'/' "$HOME"/.config/ncspot/config.toml
    else
        cat "$HOME"/.cache/wal/colors-ncspot.toml >> "$HOME"/.config/ncspot/config.toml
    fi
    
    echo "reload" | nc -U -q 0 "$HOME"/.cache/ncspot/ncspot.sock # socket location will change to $XDG_RUNTIME_DIR/ncspot/ncspot.sock in the future
}

updateKitty() {
	cp -r "$HOME"/.cache/wal/colors-kitty.conf "$HOME"/.config/kitty/wal-theme.conf &&
		[[ $(rg "^include wal-theme.conf\$" "$HOME"/.config/kitty/kitty.conf) == "" ]] &&
		echo "Pls run following line to include wal-theme to your $HOME/.config/kitty/kitty.conf:" &&
		echo "echo 'include wal-theme.conf' >> $HOME/.config/kitty/kitty.conf"
}

updateBat() {
	enabledTheme=$(rg -e "--theme=" "$HOME"/.config/bat/config | rg -v "#")
	if [[ $(echo "$enabledTheme" | wc -w) -eq 1 ]]; then
		[[ ! $(echo "$enabledTheme" | rg -e "--theme=\"base16-256\"") ]] &&
			echo "Pls run following line to include 'base16-256' theme for bat" &&
			echo "echo '--theme=\"base16-256\"' >> $HOME/.config/bat/config"

	else
		echo "Warning multiple themes are set for bat."
		echo "Pls run following line to uncomment unwanted themes and to include the 'base16-256' theme for bat"
		echo "sed -i '/--theme/s/^/#/g' $HOME/.config/bat/config &&
	        echo '--theme=\"base16-256\"' >> $HOME/.config/bat/config"
	fi
}

updateBtop++() {
	sed -i '/^color_theme = /c\color_theme = "TTY"' "$HOME"/.config/btop/btop.conf
}

updateWalfox() {
	if ! command -v pywalfox &>/dev/null; then
		echo "Pls install pywalfox via pip (fixes some errors)"
		echo "pip install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1 --break-system-packages"
		echo "pywalfox install"
	else
		pywalfox dark
		pywalfox update
	fi
}

upateHyprland() {
	cp -r "$HOME"/.cache/wal/colors-hyprland.conf "$HOME"/.config/hypr/themes/wal.conf
}

changeWallpaper

pic=$(cat "$(fd . "$HOME"/.cache/swww/ | head -1)")

wal --saturate 1.0 -i "$pic" --cols16 -n

updateCava
updateNcspot
updateKitty
updateBtop++
updateBat
updateWalfox
upateHyprland
