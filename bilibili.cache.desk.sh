#! /bin/bash

export PATH=$HOME/bin:$PATH


LST="entrys.lst"

find . -name entry.json > $LST

[[ -f $LST ]] || { echo "# 错误: $LST 文件不存在" ; exit; }

# 不能使用 while IFS= read -r line ，会出现莫名其妙的断行
for line in $(cat $LST)
do
	[[ $line != "./"* ]] && { echo "# Error line: $line" ; exit ; }

	echo "# $line"

#	line="./1101434489/c_1458814590/entry.json" # new
#	line="./114238613882591/c_29112141767/entry.json" # old
	eurl=$line

#	jstr=$(curl -s $eurl)
	jstr=$(cat $eurl)
	[[ -z $jstr ]] && exit

	ts10=$(echo $jstr | jj 'time_create_stamp');
	ts=$(( $ts10 / 1000 ));
	sTime=$(date -d "@$ts" +"%Y-%m-%d_%H%M%S");
	bvid=$(echo $jstr | jj 'bvid');
	upname=$(echo $jstr | jj 'owner_name');
	vdir=$(echo $jstr | jj 'video_quality');
	title=$(echo $jstr | jj 'page_data.download_subtitle');
	enname=$(echo -n ${sTime}_${bvid}.mkv);
	cnname=$(echo -n ${sTime}_${upname}_${title}_${bvid}.mkv | tr '"' '.' | tr "'" "." | tr '<' '.' | tr '>' '.' | tr '|' '.' | tr '?' '.' | tr '*' '.' | tr ',' '.' | tr ':' '.' | tr ',' '.' | tr '\\' '.' | tr '/' '.' | tr '+' '.' | tr ' ' '.');
	cnname=${cnname//../.};
echo "- $enname" ;
echo "- $cnname" ;

	iurl=${eurl//entry.json/$vdir}/index.json
#	jistr=$(curl -s $iurl)
	jistr=$(cat $iurl)
	[[ -z $jistr ]] && exit
	vw=$(echo $jistr | jj 'video|0|width');
	vh=$(echo $jistr | jj 'video|0|height');
	fontsize=30;
	[[ $vh -ge 999 ]] && fontsize=50

echo "- danmaku.xml, $vw x $vh, 字体大小: $fontsize -> sub.ass"
	durl=${eurl//entry.json/danmaku.xml}
#	curl -s $durl | danmaku2ass -w $vw -h $vh -s $fontsize
	cat $durl | danmaku2ass -w $vw -h $vh -s $fontsize

echo "- ffmpeg -> $enname";
	aurl=${eurl//entry.json/$vdir}/audio.m4s
	vurl=${eurl//entry.json/$vdir}/video.m4s

	if [[ -f sub.ass ]] ; then
#		echo ffmpeg -loglevel quiet -i $aurl -i $vurl -i sub.ass -c copy -c:s ass ${enname} ;
		ffmpeg -loglevel quiet -i $aurl -i $vurl -i sub.ass -c copy -c:s ass ${enname} ;
	else
#		echo ffmpeg -loglevel quiet -i $aurl -i $vurl -c copy ${enname} ;
		ffmpeg -loglevel quiet -i $aurl -i $vurl -c copy ${enname} ;
	fi

echo "- rename $enname to $cnname";
	mv $enname $cnname ;

	[[ -f sub.ass ]] && rm sub.ass ;

echo "$line" >> entrys.finished

done

echo "# done";


