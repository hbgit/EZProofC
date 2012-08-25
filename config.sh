#!/bin/bash

#Settings for EZProofC tool
#==========================================

#Getting absolute PATH

#ABS_PATH_FORTES
tmp1=`pwd`

#check path
cd $tmp1
list_file=`ls config.sh | wc -l`
if [ $list_file -ge 1 ];
then	
	echo "Running startup-config..."	
	tr1=`echo $tmp1 | sed s,/,\\\\\\\\\/,g`	
	
	#========================================================================
	# ------> write ezproofc.sh
	cat ezproofc | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > out.tmp
	rm ezproofc
	cat out.tmp > ezproofc
	chmod +x ezproofc
	rm out.tmp
	# ------> write abs_CE_v10_IN.pl
	cat modules/instanciation/abs_CE_v10_IN.pl | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/instanciation/out.tmp
	rm modules/instanciation/abs_CE_v10_IN.pl
	cat modules/instanciation/out.tmp > modules/instanciation/abs_CE_v10_IN.pl
	chmod +x modules/instanciation/abs_CE_v10_IN.pl
	rm modules/instanciation/out.tmp
	# ------> write abs_CE_v10_IN.pl
	cat modules/instanciation/go_instrument_v2_IN.pl | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/instanciation/out.tmp
	rm modules/instanciation/go_instrument_v2_IN.pl
	cat modules/instanciation/out.tmp > modules/instanciation/go_instrument_v2_IN.pl
	chmod +x modules/instanciation/go_instrument_v2_IN.pl
	rm modules/instanciation/out.tmp
	# ------> write go_insert_property.pl
	cat modules/instanciation/go_insert_property.pl | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/instanciation/out.tmp
	rm modules/instanciation/go_insert_property.pl
	cat modules/instanciation/out.tmp > modules/instanciation/go_insert_property.pl
	chmod +x modules/instanciation/go_insert_property.pl
	rm modules/instanciation/out.tmp
	# ------> write abs_CE_to_assume.pl
	cat modules/instanciation/abs_CE_to_assume.pl | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/instanciation/out.tmp
	rm modules/instanciation/abs_CE_to_assume.pl
	cat modules/instanciation/out.tmp > modules/instanciation/abs_CE_to_assume.pl
	chmod +x modules/instanciation/abs_CE_to_assume.pl
	rm modules/instanciation/out.tmp
	# ------> write go_instrument_simple_wrt.pl
	cat modules/instanciation/go_instrument_simple_wrt.pl | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/instanciation/out.tmp
	rm modules/instanciation/go_instrument_simple_wrt.pl
	cat modules/instanciation/out.tmp > modules/instanciation/go_instrument_simple_wrt.pl
	chmod +x modules/instanciation/go_instrument_simple_wrt.pl
	rm modules/instanciation/out.tmp
	# ------> write checkAllClaims.sh
	cat modules/verification/checkAllClaims.sh | sed -e "s/ABS_PATH_EZPROOFC=\"\[<??>\]\"/ABS_PATH_EZPROOFC=\"$tr1\"/g" > modules/verification/out.tmp
	rm modules/verification/checkAllClaims.sh
	cat modules/verification/out.tmp > modules/verification/checkAllClaims.sh
	chmod +x modules/verification/checkAllClaims.sh
	rm modules/verification/out.tmp	
	#========================================================================
	
	echo "   >> Status: OKAY"
else	
	echo "Sorry, you are outside from the directory where the FORTES tool was extracted. See README file."
fi



#==========================================
