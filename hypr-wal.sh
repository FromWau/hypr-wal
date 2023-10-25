#!/usr/bin/env bash

changeWallpaper() {
	monitors=(
		$(hyprctl monitors -j | jq -r '.[].name')
	)

	random_pictures=(
		$(fd ".png|.jpg|.jpeg" ~/Pictures/wallpapers/ | shuf -n ${#monitors[@]})
	)

	for i in "${!monitors[@]}"; do
		monitor=${monitors[$i]}
		random_picture=${random_pictures[$i]}

		swww img -o "$monitor" "$random_picture" \
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
			echo "echo '--theme="base16-256"' >> $HOME/.config/bat/config"

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

changeWallpaper

pic=$(cat "$(fd . "$HOME"/.cache/swww/ | head -1)")

wal --saturate 1.0 -i "$pic" --cols16 -n -q 2>/dev/null

updateCava
updateKitty
updateBtop++
updateBat
updateWalfox
