rm ./received.dat
/usr/lib/uhd/examples/rx_samples_to_file --freq 2.4895e9 --rate 2.5e5 --gain 20 --bw 5e5 --type float --file ./received.dat --args="olin_usrp04"