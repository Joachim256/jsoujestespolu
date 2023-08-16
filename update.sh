#!/bin/bash

git pull --all
git switch website
git config --global user.name "$GH_USERNAME"
git config --global user.email "$GH_USERNAME@users.noreply.github.com"

# request to get cookies
curl -sS -c ~/cookies -H "x-ig-app-id: 936619743392459" -H "Cookie: sessionid=$IGSESSIONID" https://www.instagram.com/api/v1/users/$IGUSERID/info/
printf ".instagram.com\tTRUE\t/\tTRUE\t2521843200\tsessionid\t%s\n" "$IGSESSIONID" >> ~/cookies
# request to get data
json=$(curl -sS -b ~/cookies -H "x-ig-app-id: 936619743392459" https://www.instagram.com/api/v1/users/$IGUSERID/info/)

echo $json

if [[ $(echo $json | jq '.message') == "\"checkpoint_required\"" ]]; then
	echo "Vyžadováno ověření"
	if [ -n $NTFY_URL ]; then
		url=$(echo $json | jq '.checkpoint_url')
		curl -sS -d "Vyžadováno ověření" -H "Actions: view, Ověřit, $url, clear=true" $NTFY_URL
	fi
	exit 1
fi

bio=$(echo $json | jq '.user.biography')
echo "Bio je $bio"

if [[ "$bio" == "" || "$bio" == "null" ]]; then
	echo "Nepodařilo se načíst bio"
	exit 1
fi

if [[ "$bio" == *"17.11.2022🤍"* ]] || [[ "$bio" == *"@eli._fili"* ]]; then
	echo "Jsou spolu"
	if [ $(cat prev) == "0" ]; then
 		echo "Aktualizovat stav na 1"
		if [ -n $NTFY_URL ]; then curl -sS -d "Jsou spolu" $NTFY_URL; fi
		echo "1" > prev
		git checkout main -- jestejsouspolu.html
		mv jsoujestespolu.html index.html
		git commit -am "Aktualizovat stav"
		git push
	fi
else
	echo "Nejsou spolu"
	if [ $(cat prev) == "1" ]; then
 		echo "Aktualizovat stav na 0"
		if [ -n $NTFY_URL ]; then curl -sS -d "Nejsou spolu" $NTFY_URL; fi
		echo "0" > prev
		git checkout main -- uznejsouspolu.html
		mv uznejsouspolu.html index.html
		git commit -am "Aktualizovat stav"
		git push
	fi
fi
