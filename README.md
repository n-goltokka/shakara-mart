# Shakara Mart — Advanced Database Systems Portfolio

goltokka  
MIT 8103 — Advanced Database Systems  
Project Development of an Advanced Database Systems Portfolio  
Case study: Shakara Mart (e-commerce retailer)  



Important NB: Reported results are observations from the local environment, as such, replication is guaranteed, however, there are no production performance guarantees. 

## 1. Business context and problem
Shakara Mart is modelled as an online retailer selling consumer goods across Nigeria, with business scenarios involving Lagos, Abuja and Benin City. Customers register, browse products, place orders, make payments and track deliveries. Administrators manage products, stock, fulfilment and sales reporting.

This project addresses five challenges:
1. Database design and modelling 
2. Query processing and optimisation 
3. Transactions and concurrency 
4. NoSQL and advanced data models 
5. Distributed and cloud databases 


## 2. Environment
Component | Environment used 

Operating system | Ubuntu on VMware virtual machine 
PostgreSQL administration | pgAdmin
Relational database | PostgreSQL 18.6 
No SQL database | MongoDB  


## 3. Portfolio overview, work performed and verified outcomes
P1 
Database design and modelling = Relational schema, ERD and 1NF–3NF analysis, Eight related tables with keys and constraints 

P2 
Query processing and optimisation = randomly generated values, buffers, indexing, lookup execution 

P3
Transactions and concurrency = Commit, Rollback, Read Commited, competing sessions and conditional stock updates 

P4 
NoSQL and advanced data models = MongoDB embedded order document, nested queries, update and unique index |

P5 
Distributed and cloud databases = PostgreSQL read-only, streaming and standby replication test 


#P1 — Database design and modelling

The `shakara_mart` PostgreSQL schema contains:

- `customers`
- `categories`
- `products`
- `orders`
- `order_items`
- `payments`
- `shipments`
- `inventory_movements`

The model uses primary/foreign keys to preserve relationships. Order totals can be calculated from order items rather than maintained as an additional potentially inconsistent value. The unit price recorded on an order item preserves the historical transaction price if the catalogue price changes. Inventory movements provide a record of stock changes.


#P2 — Query processing and optimisation

Performance exercise 
added approximately **10,000 synthetic customers and 50,000 synthetic orders**, resulting in **50,001 orders** in the test database. 
The measured median execution time changed from **8.857 ms** to **0.072 ms**, a reduction of approximately **99.19%** for this particular experiment. The execution plan changed from a sequential scan to indexed access.



#P3 — Transactions and concurrency

- A committed sale that reduced a selected product's stock from **10 to 9**.
- An uncommitted stock reduction that was rolled back, leaving stock at **9**.
- Two sessions under **READ COMMITTED** isolation, demonstrating that uncommitted changes were not visible to the second session.
- A competing update that produced a **row-lock timeout (SQLSTATE 55P03)**.
- A guarded stock update that returned **zero affected rows** when insufficient stock was available.
The lock test established waiting and retrying, contention and a timeout. 




#P4 — NoSQL and advanced data models

MongoDB database `shakara_mart_nosql` contains an `orders` collection used to demonstrate an embedded order document with customer, purchased item and shipping information. 
The tested order has `order_id: 2` and a total of **₦450,000**.
Practical operations included:
- Inserting and retrieving the document.
- Querying nested fields and arrays.
- Updating shipping.delivery_instruction to "Call customer before delivery".
- Creating a unique index on order_id table.
- Inspecting an indexed lookup with explain("executionStats").
- Attempting a duplicate order_id insert and observing E11000 error.




#P5 — Distributed and cloud databases

Two PostgreSQL 18 clusters were configured on the same Ubuntu VM, one primary and the other backup. 
A dedicated replication account, localhost authentication and pg_basebackup were used to initialise the standby. 
The primary's pg_stat_replication reported state = streaming and sync_state = async. 
The standby reported pg_is_in_recovery() = true and an active WAL receiver. 
A test table and row created on the primary were read successfully on the standby. An attempted standby INSERT failed with: ERROR: cannot execute INSERT in a read-only transaction. 



## 6. Key technical conclusions

- Data integrity: relational keys and normalisation establish a reliable transactional structure.
- Performance: indexing improved a measured customer-order lookup. 
- Concurrency: transaction boundaries, isolation and guarded stock updates address different integrity risks.
- NoSQL: embedded documents suit order-centric reads, but duplicated attributes require a deliberate consistency strategy.
- Replication: a standby can serve suitable read-only workloads, but asynchronous lag and shared infrastructure limit consistency and resilience guarantees.


#Reflection
Limitations: Both clusters were on the same VM and therefore a single failure domain. 
As such, not a typical independent-host high availability, automatic failover or a true DR backup. 


#8. Academic integrity and AI assistance
ChatGPT (OpenAI) assisted with explanations, experiment planning and troubleshooting discussion. The practical commands were executed in my local environment, and outputs verified. 




Status: All five practical portfolio activities completed. 
