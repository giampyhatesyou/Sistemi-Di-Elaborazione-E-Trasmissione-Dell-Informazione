#!/bin/bash
readonly Precision=9

declare -a LastLine
declare -a FirstLine

#GESTIONE DATI PROTOCOLLO TCP
LastLine=($(tail -n 1 ../data/tcp_throughput.dat)) #prendo ultima riga (-n 1 indica che prendo SOLO 1 riga)
FirstLine=($(head -n 1 ../data/tcp_throughput.dat)) # prima riga

N1=${FirstLine[0]} #ottengo dimensioni messaggio a inizio dat
N2=${LastLine[0]} #e a fine dat
#uso bc per calcolare in virgola mobile con precisione arbitraria
D1=$(bc <<< "scale=${Precision}; $N1/${FirstLine[2]}") #delay minimo
D2=$(bc <<< "scale=${Precision}; $N2/${LastLine[2]}") #delay massimo CAPIRE
BTCP=$(bc <<< "scale=${Precision}; ($N2-$N1)/($D2-$D1)") #banda
LTCP=$(bc <<< "scale=${Precision}; ($D1*$N2-$D2*$N1)/($N2-$N1)") #latenza

#GESTIONE DATI PROTOCOLLO UDP, riciclando varibili
LastLine=($(tail -n 1 ../data/udp_throughput.dat))
FirstLine=($(head -n 1 ../data/udp_throughput.dat))

N1=${FirstLine[0]}
N2=${LastLine[0]}

D1=$(bc <<< "scale=${Precision}; $N1/${FirstLine[2]}")
D2=$(bc <<< "scale=${Precision}; $N2/${LastLine[2]}")
BUDP=$(bc <<< "scale=${Precision}; ($N2-$N1)/($D2-$D1)")
LUDP=$(bc <<< "scale=${Precision}; ($D1*$N2-$D2*$N1)/($N2-$N1)")

set -e #uscire automaticamente in caso di errori

####STAMPA DEI GRAFICI####

mkdir -p ../statistics #creo, se non esiste già, cartella per salvare i grafici

#TCP
gnuplot <<-eNDgNUPLOTcOMMAND
	set term png size 900, 700
	set output "../statistics/tcp.png"
	set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"
	lbf(x) = x / ( $LTCP + x / $BTCP )
  plot lbf(x) title "Latency-Bandwidth model with L=$LTCP and B=$BTCP" with linespoints, \
	"../data/tcp_throughput.dat" using 1:2 title "TCP avarage Throughput" \
		with linespoints, \
    "../data/tcp_throughput.dat" using 1:3 title "TCP median Throughput" \
			with linespoints
	clear
eNDgNUPLOTcOMMAND

#UDP
gnuplot <<-eNDgNUPLOTcOMMAND
	set term png size 900, 700
	set output "../statistics/udp.png"
	set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"
	lbf(x) = x / ( $LUDP + x / $BUDP )
  plot lbf(x) title "Latency-Bandwidth model with L=$LUDP and B=$BUDP" with linespoints, \
    "../data/udp_throughput.dat" using 1:2 title "UDP avarage Throughput" \
		with linespoints, \
	"../data/udp_throughput.dat" using 1:3 title "UDP median Throughput" \
		with linespoints
	clear
eNDgNUPLOTcOMMAND


#ritenuto fosse opportuno stampare un terzo grafico per facilitare il confronto
gnuplot <<-eNDgNUPLOTcOMMAND
	set term png size 900, 700
	set output "../statistics/comparing.png"
	set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"
	lbf_UDP(x) = x / ( $LUDP + x / $BUDP )
	lbf_TCP(x) = x / ( $LTCP + x / $BTCP )
  	plot lbf_TCP(x) title "TCP Latency-Bandwidth model with L=$LTCP and B=$BTCP" with linespoints, \
	lbf_UDP(x) title "UDP Latency-Bandwidth model with L=$LUDP and B=$BUDP" with linespoints

	clear
eNDgNUPLOTcOMMAND