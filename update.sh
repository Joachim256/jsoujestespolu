#!/bin/bash

git pull --all
git switch website
git config --global user.name "$GH_USERNAME"
git config --global user.email "$GH_USERNAME@users.noreply.github.com"

# request to get cookies
curl -sS -c ~/cookies -H "x-ig-app-id: 936619743392459" -H "Cookie: sessionid=$IGSESSIONID" https://www.instagram.com/api/v1/users/$IGUSERID/info/
printf ".instagram.com\tTRUE\t/\tTRUE\t2521843200\tsessionid\t%s\n" "$IGSESSIONID" >> ~/cookies
# request to get data
bio=$(curl -sS -b ~/cookies -H "x-ig-app-id: 936619743392459" https://www.instagram.com/api/v1/users/$IGUSERID/info/ | jq '.user.biography')

echo "Bio is $bio"

if [[ "$bio" == "" ]]; then
	echo "Failed to fetch bio"
	exit 1
fi

if [[ "$bio" == *"17.11.2022🤍"* ]] || [[ "$bio" == *"@eli._fili"* ]]; then
	echo "Jsou spolu"
	if [ $(cat prev) == "0" ]; then
 		echo "Aktualizovat stav na 1"
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
		echo "0" > prev
		git checkout main -- uznejsouspolu.html
		mv uznejsouspolu.html index.html
		git commit -am "Aktualizovat stav"
		git push
	fi
fi
