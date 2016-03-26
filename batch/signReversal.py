# Input data should be in the form of a tab-delimited file.  Each column should represent one
# microarray and each row should represent one probe/probeset.
# Batch labels should be in the first row and expression values should be in each subsequent row.
# Probe/probeset labels should not be included.

# The first command line argument should be the input data.  If you only want to analyze one pair
# of batches instead of all possible pairs, the second and third arguments should be the names of
# these two batches.  (This analysis is commutative, so the order of the 2nd and 3rd arguments
# is irrelevant.)

import scipy.stats
import sys
import random
import numpy

# Constants
pvalCutoff = 0.05  # The cutoff for declaring a correlation significant.
minSize = 5        # The minimum size of a batch to analyze.

def sign(num):
	if num < 0:
		return -1
	if num > 0:
		return 1
	return 0

def byCategory(array, categories):
	ret = {}
	for i, category in enumerate(categories):
		if category not in ret:
			ret[category] = []
		
		ret[category].append(array[i])
	
	return ret
	
def signReversalFract(mat1, mat2, shuffle = False):
	nBothSignificant = 0
	nSignReversed = 0
	
	mat1Samples = len(mat1[0])
	mat2Samples = len(mat2[0])
	for i in xrange(len(mat1)):
		for j in xrange(i + 1, len(mat2)):
			if shuffle:
				# While this block directly manipulates the data vectors, not the batch labels,
				# it in effect permutes the batch labels.  It also permutes the individual vectors 
				# as a side effect, but does so in lockstep, such that this permutation will 
				# have no effect on any reasonable correlation metric.
				
				shuffledData = zip(mat1[i] + mat2[i], mat1[j] + mat2[j])
				random.shuffle(shuffledData)
				vec1i = [x[0] for x in shuffledData[0:mat1Samples]]
				vec1j = [x[1] for x in shuffledData[0:mat1Samples]]
				vec2i = [x[0] for x in shuffledData[-mat2Samples:]]
				vec2j = [x[1] for x in shuffledData[-mat2Samples:]]
			else:
				vec1i = mat1[i]
				vec2i = mat2[i]
				vec1j = mat1[j]
				vec2j = mat2[j]
		
			rho1, p1 = scipy.stats.pearsonr(vec1i, vec1j)
			
			if p1 > pvalCutoff:
				continue
			
			rho2, p2 = scipy.stats.pearsonr(vec2i, vec2j)
			if p2 > pvalCutoff:
				continue
				
			nBothSignificant += 1
			if sign(rho1) != sign(rho2):
				nSignReversed += 1
	
	return float(nSignReversed) / nBothSignificant

def readToCategories(filename):
	ret = {}
	file = open(filename)
	years = file.next().strip().split("\t")
	
	for line in file:
		numbers = [float(x) for x in line.strip().split("\t")]
		byYear = byCategory(numbers, years)
		
		for year, yearData in byYear.iteritems():
			if year not in ret:
				ret[year] = []
			ret[year].append(yearData)
			
	return ret

def standardizeRows(mat):
	ret = []
	for i, row in enumerate(mat):
		mean = numpy.mean(row)
		stdev = numpy.std(row)
		ret.append([(x - mean) / stdev for x in row])
	
	return ret
	
def main(args):
	if len(args) < 2:
		print >>sys.stderr, "Please provide an input file as a command line argument."
		exit()

	data = readToCategories(args[1])
	
	# Allow for the user to input just a single pair of years as the second and third command line
	# args.
	if len(args) == 4:
		years = args[2:]
	else:
		years = data.keys()
	
	for year, mat in data.iteritems():
		if len(mat[0]) < minSize:
			continue
		data[year] = standardizeRows(mat)
	
	print "Year 1\tYear2\tUnshuffled Sign Reversal Fract\tShuffled Sign Reversal Fract"	
	for i in xrange(len(years)):
		year1 = years[i]
		if len(data[year1][0]) < minSize:
			continue
		for j in xrange(i + 1, len(years)):
			year2 = years[j]
			if len(data[year2][0]) < minSize:
				continue
			print year1, "\t", year2, "\t", signReversalFract(data[year1], \
				data[year2]), "\t", signReversalFract(data[year1], data[year2], True)
			sys.stdout.flush()
			
if __name__ == "__main__":
	try:
		import psyco
		psyco.full()
	except:
		print >>sys.stderr, "Psyco not found.  This code may execute slowly."
		
	main(sys.argv)
	
	