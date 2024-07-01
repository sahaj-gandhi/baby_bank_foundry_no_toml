# create an script to add dummy modifications to a placeholder file

current_date=$(date)
echo $current_date >> dummy.txt

git add dummy.txt
git commit -m "dummy modification at $current_date"
git push

