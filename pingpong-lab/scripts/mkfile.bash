#!/bin/bash

set -e

if [[ $# != 6 ]] ; then printf "\nError: expected arguments parameters\n\n" ; exit 1; fi

#dichiarazione valori presi dagli argomenti in argv
readonly MinSize=$1
readonly MaxUdpSize=$2
readonly MaxTcpSize=$3
readonly NoRepeat=$4
readonly IpAddr=$5
readonly Port=$6
readonly PngFilename="../data/throughput.png"
readonly TcpDataFilename="../data/tcp_throughput.dat"
readonly UdpDataFilename="../data/udp_throughput.dat"
readonly Makefile="../data/Makefile"
readonly BrokenExt='.broken' 

declare -a UdpSizes
declare -a UdpFilenames
for (( (UdpIndex=1 , sz=$MinSize, mid=$MinSize/2) ; $sz <= $MaxUdpSize ; (++UdpIndex , mid=$sz, sz*=2) )) do 
	UdpSizes[$UdpIndex]=$sz
	UdpFilenames[$UdpIndex]=../data/udp_$sz.out
	let mid+=$sz
	if (( $mid <= $MaxUdpSize )) ; then let ++UdpIndex ; UdpSizes[$UdpIndex]=$mid ; UdpFilenames[$UdpIndex]=../data/udp_$mid.out ; fi
done

declare -a TcpSizes
declare -a TcpFilenames
for (( (TcpIndex=1 , sz=$MinSize, mid=$MinSize/2) ; $sz <= $MaxTcpSize ; (++TcpIndex , mid=$sz, sz*=2) )) do 
	TcpSizes[$TcpIndex]=$sz
	TcpFilenames[$TcpIndex]=../data/tcp_$sz.out
	let mid+=$sz
	if (( $mid <= $MaxTcpSize )) ; then let ++TcpIndex ; TcpSizes[$TcpIndex]=$mid ; TcpFilenames[$TcpIndex]=../data/tcp_$mid.out ; fi
done

rm -f ${Makefile}

printf "PINGPONGADDR=%s\nPINGPONGPORT=%s\nTCP_EXE=../bin/tcp_ping\nUDP_EXE=../bin/udp_ping\n\n" $IpAddr $Port  > ${Makefile}
printf "all: throughput ../data\n\n" >> ${Makefile}
printf "../data:\n\tmkdir ../data\n\n" >> ${Makefile}
printf "throughput: ${PngFilename}\n\n" >> ${Makefile}
printf "all_data: all_udp_data all_tcp_data\n\nall_udp_data:" >> ${Makefile}
for (( indx=1 ; $indx < $UdpIndex ; ++indx )) ; do printf " %s" ${UdpFilenames[$indx]} >> ${Makefile}; done
printf "\n\nall_tcp_data:" >> ${Makefile}
for (( indx=1 ; $indx < $TcpIndex ; ++indx )) ; do printf " %s" ${TcpFilenames[$indx]} >> ${Makefile}; done

for (( indx=1 ; $indx < $UdpIndex ; ++indx )) do 
	out=${UdpFilenames[$indx]}
	printf "\n\n%s:\n\t\$(UDP_EXE) \$(PINGPONGADDR) \$(PINGPONGPORT) %s %s > %s || mv -f %s %s${BrokenExt}" $out ${UdpSizes[$indx]} $NoRepeat $out $out $out >> ${Makefile}
done

for (( indx=1 ; $indx < $TcpIndex ; ++indx )) do 
	out=${TcpFilenames[$indx]}
	printf "\n\n%s:\n\t\$(TCP_EXE) \$(PINGPONGADDR) \$(PINGPONGPORT) %s %s > %s || mv -f %s %s${BrokenExt}" $out ${TcpSizes[$indx]} $NoRepeat $out $out $out >> ${Makefile}
done

printf "\n\n${PngFilename}: ${TcpDataFilename} ${UdpDataFilename}\n\t../scripts/gplot.bash\n\n" >> ${Makefile}
printf "${UdpDataFilename}: all_udp_data\n\t../scripts/collect_throughput.bash udp\n\n" >> ${Makefile}
printf "${TcpDataFilename}: all_tcp_data\n\t../scripts/collect_throughput.bash tcp\n\n" >> ${Makefile}

printf "clean:\n\trm -f ${PngFilename} ${TcpDataFilename} ${UdpDataFilename}" >> ${Makefile}
for (( indx=1 ; $indx < $UdpIndex ; ++indx )) do
	f=${UdpFilenames[$indx]}
	printf " %s %s${BrokenExt}" $f $f >> ${Makefile} 
done
for (( indx=1 ; $indx < $TcpIndex ; ++indx )) do
	f=${TcpFilenames[$indx]}
	printf " %s %s${BrokenExt}" $f $f >> ${Makefile} 
done
printf "\n\n"  >> ${Makefile}

