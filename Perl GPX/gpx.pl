# ***********************
# GPX.pl
# Author: Jelle De Bock
# ***********************
#Parses a GPX file and shows a quick summary of it.
# -distance
# -total ridetime
# -average number of satelites
# -start time
# -average speed

#!/usr/bin/perl

#use re 'debug';
use Math::Trig;
use Math::Trig 'pi';
use Data::Dumper;
use Time::Local;

$num_args = @ARGV;
my $gpx_file;
if($num_args!=1){
    print "[USAGE] gpx.pl [file.gpx]\n";
    exit -1;
}
if( $ARGV[0] =~ /.*\.gpx/ ){
    open($gpx_file, '<', $ARGV[0]) or do{ print "Could not open the gpx file!\n"; exit(-1) };
}
elsif( $ARGV[0]=="--info" ){
    print "A Perl GPX parser written by Jelle De Bock\n";
    print "[USAGE] gpx.pl [file.gpx]\n";
    print "\tExtracts the following from a GPX file\n";
    print "\t\t-a name for the track\n";
    print "\t\t-distance\n";
    print "\t\t-total ridetime\n";
    print "\t\t-average number of satelites (if available)\n";    
    print "\t\t-start time\n";
    print "\t\t-average speed\n";
    print "\t\t-total number of waypoints\n";
    exit 0;
}
else{
    print "Please specify a GPX file...\n";
    exit(-1);
}
my $name;
my %start_time;
my @trackpoints;
my @months=('January','February','March','April','May','June','July','August','September','November','December');
my $avg_satelites;   #the average number of satelites during the ride
my $trackpoint_length;
my $duration_sec=0;
my $previous_epoch; #used to calculate activity duration
while(<$gpx_file>){
    #title
    if( /^\s*<name>(.*)<\/name>\s*$/ ){
	$name = $1;
    }
    #start time or duration
    if ( /^\s*<time>(.{20})<\/time>\s*$/){
	$timestring = $1;  #Using ISO 8601 format (always UTC time)
	$timestring =~ /
                         (\d{4})        #year
                         -              #separator(not needed)
                         (\d{2})        #month
                         -              #separator
                         (\d{2})        #day
                         T              #literal T
                         (\d{2})        #hours
                         :              #separator
                         (\d{2})        #minutes
                         :              #separator
                         (\d{2})        #seconds
                         Z              #Zulu time 
                       /x;
	my $epoch=getEpochTime($6,$5,$4,$3,$2,$1);
	if(!(%start_time)){
	    $start_time{'year'}=$1;
	    $start_time{'month'}=$2;
	    $start_time{'day'}=$3;
	    $start_time{'hours'}=$4;
	    $start_time{'minutes'}=$5;	
	    $start_time{'seconds'}=$6;
	    @t = localtime(time);
	    $gmt_offset_in_seconds = timegm(@t) - timelocal(@t);
	    $start_time{'UTC_offset'}=$gmt_offset_in_seconds;
	    $previous_epoch=$epoch;
	}
	#In <time> tag in trkpt
	else{
	    $duration_sec += ($epoch-$previous_epoch);
	    $previous_epoch=$epoch;
	}
   }
    #waypoints
    if( /^\s*<trkpt lat="(\d+\.\d+)"\slon="(\d+.\d+)">\s*$/ ){
	$helper={};
	$helper->{'lat'}=$1;
	$helper->{'lon'}=$2;
	push @trackpoints,$helper;
    }
    #satelites
    if( /^\s*<sat>(\d+)<\/sat>\s*$/ ){
	$avg_satelites+=$1;
    }
}

$distance=0.0;
$trackpoint_length = @trackpoints;
for($i=0;$i<$trackpoint_length-1;$i++){
    $co1 = $trackpoints[$i];
    $co2 = $trackpoints[$i+1];
    $result = haversine($$co1{'lat'},$$co2{'lat'},$$co1{'lon'},$$co2{'lon'});
    $distance=($distance+$result);
}

$avg_speed = $distance/$duration_sec*3600;

printf "Name of GPX track : %s.\n",$name;
printf "Total distance of GPX track: %.4f.\n",$distance;
printf "Average speed: %.2f.\n",$avg_speed;
printf "Start time of track: %02d %s %4d %02d:%02d:%02d.\n",
                                    $start_time{'day'},
                                    $months[$start_time{'month'}-1],
                                    $start_time{'year'},
                                    $start_time{'hours'},
                                    $start_time{'minutes'},
                                    $start_time{'seconds'};
printf "Duration of GPX track : %02d:%02d:%02d.\n",$duration_sec/3600,$duration_sec % 3600/60,$duration_sec % 60;
printf "Number of waypoints: %d.\n",$trackpoint_length;
$avg_satelites/=$trackpoint_length;     #calculate average (we have the sum)
printf "Average number of satelites during %s: %s.\n",$name,($avg_satelites==0?"N/A":$avg_satelites); 
sub getEpochTime{
    my $epoch = timegm($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);
 
    return $epoch;
}
sub haversine{
    ($lat1,$lat2,$lon1,$lon2)=@_;
#    print ("lat1=$lat1,lat2=$lat2,lon1=$lon1,lon2=$lon2\n");
    $theta1 = $lat2-$lat1;
    $theta2 = $lon2-$lon1;
    #convert to radians
    $theta1*=(pi/180);
    $theta2*=(pi/180);
    #calculate haversine theta1
    $hav1=(1-cos($theta1))/2;
    $hav2=(1-cos($theta2))/2;
    #calculate distance
    $d_div_r = $hav1+ cos($lat1 * pi/180)* cos($lat2 * pi/180) * $hav2;
    $radius=6371;
    my $distance=2*$radius * asin(sqrt($d_div_r));
    return $distance;
}
