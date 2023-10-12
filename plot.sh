#i/bin/bash

#rebuild executable
make clean && make collatz

#
# SOURCES USED:
#
# BASH Reference Manual (Gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
# Gnuplot reference manual (gnuplot.info/docs_5.4/Gnuplot_5_4.pdf)
#
#


#reset output file, sending output to standard error (if files do not exist)
rm *.dat 2>/dev/null 

totalSteps=0
for num in {2..10000}
do
	
	#Creating the max length variable and couting length variable
	max=0
	count=0
	
	#Looping through all the values returned by collatz.c with input of $num (The counter)
	while read current
	do
		# Adding one to the count which will count the total number of lines returned
		count=$((count+1))
		
		#checks if current > max, if it is, set max to the current value
		if [ $current -gt $max ]
		then
			max=$current
		fi
	done < <(./collatz -n $num)
	#Line above allows collatz sequence to be looped through without deleting the inside variables
	#once it exits the loop (by using here string)!
	
	#Total length from start of n
	totalSteps=$((totalSteps + count))
	
	#GRAPH ONE: Plotting Length to graph_one.dat: "n, length"
	printf "$num $count\n" >> graph_one.dat
	
	#GRAPH TWO: Plotting found maximum to graph_two.dat: "n, max"
	printf "$num $max\n" >> graph_two.dat

	#GRAPH 3: Plotting found length to temporary2.dat to sort after loop: "length"
	printf "$count\n" >> temporary2.dat
	
	#GRAPH 4: Plotting average length up to current n value: "avg"
	avg=$(( totalSteps / (num -1) ))
	printf "$avg\n" >> graph_four.dat
	
done

	#GRAPH 3: Sorting all found lengths for counting (uniq -c command file must be sorted to work properly)
	sort -n temporary2.dat > testing.dat
	
	#GRAPH 3: Counting occurances of values for histogram: "value, occurances"
	#Also fixing strange formatting, removing white spaces and swapping (y, x) --> (x, y)
	printf "$(uniq -c testing.dat)" | awk '{print $2 " " $1}' > graph_three.dat

#Time to plot the data we collected!
gnuplot <<END
	#Resetting gnuplot settings to avoid accidental errors
	reset
	
	
	#SETTING UP GRAPH ONE
	set terminal pdf
	set output "graph_one.pdf"
	set xlabel "n"
	set ylabel "length"
	set yrange [0:]
	set title "Collatz Sequence Lengths"
	set key off
	plot "graph_one.dat" using 1:2 ps 0.1
	
	
	#SETTING UP GRAPH TWO 
	set output "graph_two.pdf"
	set ylabel "value"
	set yrange [0:100000]
	set title "Maximum Collatz Sequence Value"
	plot "graph_two.dat" using 1:2 ps 0.1
	
	
	#SETTING UP GRAPH THREE 
	reset
	set terminal pdf
	set xlabel "length"
	set ylabel "frequency"
	set xtics 0, 25, 225
	set title "Collatz Sequence Length Histogram"
	set key off
	set xrange [0:225]
	set yrange [0:]
	set boxwidth -2
	set style fill solid 1.0 border -1
	set output "graph_three.pdf"
	set xrange [:]
	set style histogram clustered gap 2
	plot "graph_three.dat" u 1:2:(1) w boxes 
	
	
	#SETTING UP GRAPH FOUR
	reset
	set key off
	set terminal pdf
	set title "Cumulative Length Average"
	set xlabel "n"
	set ylabel "Length Average to n"
	set output "graph_four.pdf"
	plot "graph_four.dat" with lines
	
END
echo "Done making graphs!"
