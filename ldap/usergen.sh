#!/bin/bash

# Produce a random number. Uses bash's RANDOM variable, takes a series of
# samples enough to make the numbers range from zero to the number of lines
# in /usr/share/dict/words.
function randnumber {
        availablewords=`wc -l /usr/share/dict/words | awk '{print $1;}'`
        rounds=$((availablewords/32768))
        count=0
        fgasdf=0
        while test $count -le $rounds; do
                rand=$RANDOM
                fgasdf=$((fgasdf+rand))
                count=$((count+1))
        done
        echo $fgasdf
}

# Extract a random line out of /usr/share/dict/words
function randword {
        randnum=`randnumber`
        word=`cut --delimiter='
' -f $randnum /usr/share/dict/words`
        echo $word;
}

# Extract line from /usr/share/dict/words that doesn't contain a "'" character,
# as presumably a lot of our code will burst into flames if it encounters that.
function cleanword {
	while true; do
		bees=`randword`
		echo $bees | grep \' > /dev/null 2>&1
		if test $? = 1; then
			echo $bees
			exit
		fi
	done
}

# Map a number from 1 to 54 to a textual TLA.
function tla {
  beans="A"
  num=$1
  if test $num -le 25; then
    beans="${beans}A"
  elif test $num -le 51; then
    beans="${beans}B"
    num=$((num-26))
  else
    beans="${beans}C"
    num=$((num-51))
  fi

  num=$((num+65))
  octnum=`echo "ibase=10;obase=8;$num" | bc`
  char=`printf "\\\\$octnum"`
  beans="${beans}${char}"
  echo $beans
}

# Create a new user with random names and emails. Optionally a student or a
# teacher.
function newuser {
      collegecount=$1
      leteam=$2
      fname=`cleanword`
      lname=`cleanword`
      email="`cleanword`@srobo.org"
      username=`./getusername.py $leteam $fname $lname`
      ./userman user add $username $fname $lname $email
      ./userman group addusers college-${collegecount} $username
      ./userman group addusers team-${leteam} $username

      if test $3 = 0; then
        group="teachers"
      else
        group="students"
      fi

      ./userman group addusers $group $username
}

# Various parameters; the number of members of a team is distributed ish
# between 3 and 10 members.
teamspread=(4 8 8 10 10 8 4 4)

teamcount=0
teammembers=3
collegecount=1

for var in "${teamspread[@]}"
do
  for i in `seq $var`; do
    leteam=`tla $teamcount`
    ./userman group create college-${collegecount}
    ./userman group create team-${leteam}
    # Generate teacher
    newuser $collegecount $leteam 0

    # Generate students
    for j in `seq $teammembers`; do
      newuser $collegecount $leteam 1
    done

    teamcount=$((teamcount+1))
    collegecount=$((collegecount+1))
  done
  teammembers=$((teammembers+1))
done
