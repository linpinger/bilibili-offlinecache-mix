#! /data/data/com.termux/files/usr/bin/bash

export PATH=$HOME/bin:$PATH

# cd /sdcard/Android/data/tv.danmaku.bili/download/; find . -name entry.json > /sdcard/entrys.lst

cd /sdcard/;

HR="http://127.0.0.1:2333"
LST="entrys.lst"

[[ -f $LST ]] || { echo "# 错误: $LST 文件不存在" ; exit; }

while IFS= read -r line
do

	echo "# $line"

#	line="./1101434489/c_1458814590/entry.json" # new
#	line="./114238613882591/c_29112141767/entry.json" # old
	eurl=$HR/$line

	jstr=$(curl -s $eurl)
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
	jistr=$(curl -s $iurl)
	[[ -z $jistr ]] && exit
	vw=$(echo $jistr | jj 'video|0|width');
	vh=$(echo $jistr | jj 'video|0|height');
	fontsize=30;
	[[ $vh -ge 999 ]] && fontsize=50

echo "- danmaku.xml, $vw x $vh, 字体大小: $fontsize -> sub.ass"
	durl=${eurl//entry.json/danmaku.xml}
	curl -s $durl | danmaku2ass -w $vw -h $vh -s $fontsize

echo "- ffmpeg -> $enname";
	aurl=${eurl//entry.json/$vdir}/audio.m4s
	vurl=${eurl//entry.json/$vdir}/video.m4s

	if [[ -f sub.ass ]] ; then
		ffmpeg -loglevel quiet -i $aurl -i $vurl -i sub.ass -c copy -c:s ass ${enname} ;
	else
		ffmpeg -loglevel quiet -i $aurl -i $vurl -c copy ${enname} ;
	fi

echo "- rename $enname to $cnname";
	mv $enname $cnname ;

	[[ -f sub.ass ]] && rm sub.ass ;

echo "$line" >> ${LST}.finished

done < $LST

echo "# done";


