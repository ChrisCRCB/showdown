@echo off
flutter build web --release --base-href="/showdown/" & scp -Cr build\web chris@backstreets.site:www/backstreets.site/html/showdown