# Practice Building a blockchain

https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

https://github.com/dvf/blockchain

## Create a Blockchain class (manages the chain)

        - in constructor:

            - Create 2 lists:

               - one to store blockchain

                      `self.chain = []`

               - one to store transactions

                      `self.current_transactions = []`


     - A `Block` contains:

          - an `index`

          - a `timestamp`

          - a `list of transactions`

          - a `proof`

          - a `hash` of the previous block....what gives blockchains immutability


    - Add Transactions to a Block via `new_transaction()`


        - returns the index of the block ... transaction will be added to—the next one to be mined.


## Creating New Blocks


         - Blockchain needs to be seeded by a `genesis block` (ie., initial....created in constructor) + add a `proof` (ie., proof of work) to `genesis` block


         - Other methods to create w/in constructor:


              - `new_block()`

              - `new_transaction()`

              - `hash()`



## Proof of Work


      -  `PoW` = Proof of Work algorithm

              -  how new Blocks are created or mined

              - discover a number which solves a problem



### Implementing basic Proof of Work

      - see `def proof_of_work(self, last_proof):`

      - ...could modify the number of leading zeroes, but not necessary


## Blockchain as an API


    - ` Python Flask Framework` -> talk to blockchain over the web via HTTP requests


        - 3 methods:


              - `/transactions/new`

              - `/mine` -> mine a new block

              - `/chain` -> return the full Blockchain



## Set up Flask


      - form a single node

            - ` app = Flask(__name__) `


      - create `routes` via `@app.route`


      - `node_identifier = str(uuid4()).replace('-', '')` -> Create a random name for node


      - `The Transactions Endpoint` -> request user sends to the server


          - ` {
               "sender": "my address",
               "recipient": "someone else's address",
               "amount": 5
              } `


## The Mining Endpoint


    - Calculate the Proof of Work

    - Reward the miner (us)

    - Forge the new Block + add it to the chain

    - the `recipient` of the mined block = address of our node


# Interacting with our Blockchain




      - Start server locally (Mac):

            ` pip3 install requests `

            ` pip3 install flask `

            `python3 blockchain.py `



      - Start server via `Docker`:


          - ` docker build -t blockchain . `


          - ` docker run --rm -p 80:5000 blockchain `


                - To add more instances, vary the public port number before the colon:


                ` $ docker run --rm -p 81:5000 blockchain

                $ docker run --rm -p 82:5000 blockchain

                $ docker run --rm -p 83:5000 blockchain `


      - in `Postman` -> `mine` a block w/ a `GET`:


          - ` http://localhost:5000/mine `



      - create a new transaction via `POST` w/ body containing transaction structure:


            - ` http://localhost:5000/transactions/new `

                    - EX return:  

                          `"message": "Transaction will be added to Block 3`


            - OR send POST via `cURL`

                    ` curl -X POST -H "Content-Type:   application/json" -d '{
                       "sender": "d4ee26eee15148ee92c6cd394edd974e",
                       "recipient": "someone-other-address",
                       "amount": 5
                      }' "http://localhost:5000/transactions/new" `


                      - stop + restart server (= mining 2 blocks so for)+ resend POST req to create yet another new block


                  - inspect `full chain` via `GET`:


                      - ` http://localhost:5000/chain `



# Consensus


     - `Consensus Algorithm` -> deals w/ problem of consensus...need this to have more than one node (ie., decentralization)


## Registering new Nodes


    - create more `endpoints` -> let node know about other nodes on network


    -` /nodes/register` -> accept list of nodes via URLs


    - `/nodes/resolve` -> implement our Consensus Algorithm -> resolves any conflicts


    - create method for registering nodes via `constructor` function in `blockchain.py`:


          - `  def register_node(self, address): `

          - `set()` -> holds list of nodes -> = `idempotent` ->  no matter how many times a a specific node is added, it appears exactly once


## Implementing the Consensus Algorithm    


    - `conflict` -> one node has a different chain to another

    - Solution:


        - rule making the longest valid chain authoritative ... ie., = the de-facto one in the network = algorithm to reach Consensus amongst nodes

              - `valid_chain()` -> checks if a chain is valid..loops through each block.. verifies hash + the proof

              - `resolve_conflicts()` -> loops through all neighboring nodes, downloads their chains + verifies them

                  - If a valid chain is found w/ length > than ours, de-facto chain is replaced



      - register two endpoints to API:


            - `@app.route('/nodes/register', methods=['POST'])`

            - `@app.route('/nodes/resolve', methods=['GET'])`


            - create a 2nd node on another post + register w/ current node:


                - `POST` req -> `http://localhost:5000/nodes/register `

                - body:


                      - ` {
                            "nodes":  ["http://127.0.0.1:5001"]
                           } `


              - mine new Blocks on node2...chain should be longer //running into errors here...com back later...retry


              - call `GET` `/nodes/resolve` on node 1, where the chain was replaced by the Consensus Algorithm:


                    ` http://localhost:5000/nodes/resolve `


### NOTE:

    - Proof of work is not tied to the transaction history:


        -  means that somebody could re-write the transaction history, compute the new block hashes, and re-use your proofs of work...creating a new longest chain


        -  should include the hash of the last block in the proof of work for the next block to prevent proofs of work from being recycled on other chains
