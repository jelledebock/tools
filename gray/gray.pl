use Data::Dumper;

#je kan twee argumenten meegeven
#  $aantal_bits verplicht aantal tot waar je wilt berekenen 
#  $delimiter waarmee de reeks wordt uitgeschreven (vb. een , vergemakkelijkt openen in Excel om zo makkelijk afstand tussen twee knopen te vinden
$aantal_bits = $ARGV[0];
$delimiter = $ARGV[1];

if($aantal_bits==0){
    return "0";
}

#Dit moet minimaal aan de array toegevoegd worden
push @gray_code, [0];
push @gray_code, [1];

#$i stelt het i-de bit in de gray code voor
for($i=1;$i<$aantal_bits; $i++){
    #we hebben een kopie nodig van de huidige gray code array
    my @tmp = @gray_code;

    #laatste (voorlopige) index hebben we nodig om hierna 0'en en 1'en te plaatsen
    $last_index = $#gray_code;

    #voeg alle elementen nogmaals toe aan de gray-code array, maar in omgekeerde volgorde
    foreach $val (reverse(@tmp)){
	push @gray_code, [@{$val}];
    }
    
    #de nieuwe hoogste index in de gray-code array
    $new_last_index=$#gray_code;

    #het eerste (oorspronkelijke) deel van de graycode array wordt vooraf gegaan met 0'en
    for($j=0 ; $j<=$last_index ; $j++){
	unshift @gray_code[$j],0;
    }
    
    #aan het tweede (omgekeerde van oorspronkelijke) deel voegen we een 1 toe  
    for($j=$last_index + 1 ; $j<=$new_last_index ; $j++){
	unshift @gray_code[$j],1;
    }
}

#print de graycode array met eventueel de delimiter
$size = @gray_code;
print "$size\n";
for($i=0;$i<$size;$i++){
    for($j=0;$j<$aantal_bits;$j++){
	print "$gray_code[$i][$j] $delimiter";
    }
    print "\n";
}

