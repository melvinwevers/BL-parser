from pyelasticsearch import ElasticSearch

import json
import codecs
import glob
import os

# ElasticSearch settings
ES_CLUSTER = 'http://localhost:9200/'
ES_INDEX = 'kb'
ES_TYPE = 'doc'
es = ElasticSearch(ES_CLUSTER)


if __name__ == "__main__":
  import argparse
  oArgParser = argparse.ArgumentParser()
  oArgParser.add_argument("INPUT_DIR", metavar="DIR",
                          help="Directory with JSON files")
  oArgs = oArgParser.parse_args()

  for sJsonFile in glob.glob(os.path.join(oArgs.INPUT_DIR, "*.json")):
    fhFile = codecs.open(sJsonFile, mode='r', encoding='utf8')
    sJSON = fhFile.read()
    aArticles = json.loads(sJSON)
    fhFile.close()

    # Dit is even om te laten zien dat het werkt
    #for dArticle in aArticles:
    #  print "Title: %s" % dArticle['article_dc_title'].encode("utf8")
    #  print "Text: %s" % dArticle['text_content'][0:120].encode("utf8")
    #  print

    # Het zou me niet verbazen als dit ook werkt:
    es.bulk_index(ES_INDEX, ES_TYPE, aArticles, id_field='_id')



