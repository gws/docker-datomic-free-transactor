(require '[datomic.api :as d])
(require '[clojure.pprint :refer [pprint]])

;; This database is running under the Dockerized transactor!
(def database-uri
  (str "datomic:free://localhost:4334/" (d/squuid)))

(def conn
  (do
    (d/create-database database-uri)
    (d/connect database-uri)))

(def db (d/db conn))

(def schema-info
  (d/q '{:find [[(pull ?id [* {:db/valueType [:db/ident]}
                              {:db/cardinality [:db/ident]}
                              {:db/unique [:db/ident]}]) ...]]
         :where [[?e :db/ident ?id]
                 [_ :db.install/attribute ?e]]}
       db))

(pprint schema-info)

(d/shutdown true)
