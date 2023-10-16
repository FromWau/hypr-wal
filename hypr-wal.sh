#!/bin/bash

changeWallpaper() {
	# Get the list of monitors
	monitors=(
		$(hyprctl monitors -j | jq -r '.[].name')
	)

	# Get a list of random pictures from the specified directory
	random_pictures=(
		$(fd ".png|.jpg|.jpeg" ~/Pictures/wallpapers/ | shuf -n ${#monitors[@]})
	)

	# Loop through each monitor and set a random wallpaper
	for i in "${!monitors[@]}"; do
		# Get the current monitor and random picture
		monitor=${monitors[$i]}
		random_picture=${random_pictures[$i]}

		# Set the wallpaper for the current monitor
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
	[[ ! -e "$(bat --config-dir)"/themes ]] && mkdir -p "$HOME"/.config/bat/themes
}

updateBtop++() {
	sed -i '/^color_theme = /c\color_theme = "TTY"' "$HOME"/.config/btop/btop.conf
}

changeWallpaper

pic=$(cat "$(fd . "$HOME"/.cache/swww/ | head -1)")

wal -i "$pic" --cols16 -n -q 2>/dev/null

updateCava
updateKitty
updateBtop++
#updateBat
