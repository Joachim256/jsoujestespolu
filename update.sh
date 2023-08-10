#!/bin/bash

git switch website
git pull
git config --global user.name "Joachim256"
git config --global user.email "Joachim256@users.noreply.github.com"

# request to get cookies
curl -sS -c ~/cookies -H "x-ig-app-id: 936619743392459" -H "Cookie: sessionid=$IGSESSIONID" https://www.instagram.com/api/v1/users/10005941662/info/
printf ".instagram.com\tTRUE\t/\tTRUE\t2521843200\tsessionid\t%s\n" "$IGSESSIONID" >> ~/cookies
# request to get data
bio=$(curl -sS -b ~/cookies -H "x-ig-app-id: 936619743392459" https://www.instagram.com/api/v1/users/10005941662/info/ | jq '.user.biography')

echo "Bio is $bio"

if [ "$bio" == "" ]; then
	echo "Failed to fetch bio"
	exit 1

if [[ "$bio" == *"17.11.2022🤍"* ]] || [[ "$bio" == *"@eli._fili"* ]]; then
	if [ $(cat prev) == "0" ]; then
		echo "1" > prev
		git checkout main -- jestejsouspolu.html
		mv jsoujestespolu.html index.html
		git commit -am "Aktualizovat stav"
		git push
	fi
else
	if [ $(cat prev) == "1" ]; then
		echo "0" > prev
		git checkout main -- uznejsouspolu.html
		mv uznejsouspolu.html index.html
		git commit -am "Aktualizovat stav"
		git push
	fi
fi
