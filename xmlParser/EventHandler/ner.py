import logging
import csv
import sys
import nltk
import re
import time
from nltk.corpus import stopwords
from collections import defaultdict

stoplist = stopwords.words('dutch')

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
csv.field_size_limit(sys.maxsize)

from gensim import corpora, models, similarities

f = open('verfrissend.csv') 
csv_f = csv.reader(f, delimiter ='\t')
text_content = []

for row in csv_f:
	text_content.append(row[27])

#remove stopwords and tokenize
texts = [[word for word in document.lower().split() if word not in stoplist]
		for document in text_content]

		
def processLanguage():
	try:
		for item in texts:
			tokenized = nltk.word_tokenize(item)
			tagged = nltk.pos_tag(tokenized)
			print tagged
			
			namedEnt = nltk.ne_chunk(tagged)
			namedEnt.draw()
			
			time.sleep(1)
			
	except Exception, e:
		print str(e)
		
processLanguage()




