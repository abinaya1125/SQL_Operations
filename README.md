# Comprehensive MySQL Queries Collection

A comprehensive collection of MySQL queries organized by topic, ranging from beginner to advanced level. This collection is designed for learning, interview preparation, and portfolio demonstration.

## 📁 Directory Structure

```
SQL queries/
├── Database_Schema.sql                    # Complete database schema and sample data
├── Basic_SELECT_Filtering/
│   └── Basic_SELECT_Queries.sql           # Queries 1-15: Basic SELECT & Filtering
├── Aggregate_Functions_GROUP_BY/
│   └── Aggregate_Functions.sql            # Queries 16-30: Aggregate Functions & GROUP BY
├── JOINs/
│   └── JOIN_Queries.sql                   # Queries 31-50: All types of JOINs
├── Subqueries/
│   └── Subqueries.sql                     # Queries 51-65: Correlated & Non-Correlated Subqueries
├── Functions/
│   └── Functions.sql                      # Queries 146-160: User-Defined Functions
├── Indexing_Performance/
│   └── Indexing_Performance.sql           # Queries 81-110: Indexing & Performance Optimization
├── Views/
│   └── Views.sql                          # Queries 111-128: Views
├── Stored_Procedures/
│   └── Stored_Procedures.sql              # Queries 129-145: Stored Procedures
├── Triggers/
│   └── Triggers.sql                       # Queries 161-175: Triggers
├── Transactions/
│   └── Transactions.sql                   # Queries 176-190: Transactions
├── Date_String_Functions/
│   └── Date_String_Functions.sql          # Queries 211-240: Date & String Functions
└── README.md                              # This file
```

## 🚀 Getting Started

### 1. Setup the Database

First, execute the database schema to create all necessary tables and sample data:

```sql
-- Execute the schema file
SOURCE "Database_Schema.sql";
```

### 2. Choose Your Topic

Navigate to any topic folder that interests you. Each folder contains:

- SQL queries from basic to advanced
- Clear comments explaining each query
- Real-world use cases and scenarios

### 3. Execute Queries

You can execute queries individually or run entire files. Each query is self-contained and ready to run.

## 📚 Query Categories

### 🔰 Beginner Level (Queries 1-30)
- **Basic SELECT & Filtering**: Simple data retrieval and filtering
- **Aggregate Functions & GROUP BY**: Data summarization and grouping

### 🟡 Intermediate Level (Queries 31-110)
- **JOINs**: INNER, LEFT, RIGHT, SELF, and complex multi-table joins
- **Subqueries**: Correlated and non-correlated subqueries
- **Indexing & Performance**: Query optimization and indexing strategies

### 🔴 Advanced Level (Queries 111-240)
- **Views**: Complex views with joins and aggregations
- **Stored Procedures**: Parameterized procedures with error handling
- **Functions**: User-defined functions with complex logic
- **Triggers**: Automated database operations
- **Transactions**: ACID compliance and error handling
- **Date & String Functions**: Advanced date/time and string manipulation

## 💡 Sample Database Schema

The collection uses a consistent sample database with the following tables:

- **departments**: Company departments with budgets and managers
- **employees**: Employee information with salaries and hierarchies
- **customers**: Customer data with order history
- **products**: Product catalog with pricing and inventory
- **orders**: Order management with status tracking
- **order_details**: Detailed order line items
- **students**: Student academic records
- **courses**: Course catalog
- **enrollments**: Student course enrollments

## 🎯 Learning Path

### For Beginners
1. Start with `Basic_SELECT_Filtering/`
2. Move to `Aggregate_Functions_GROUP_BY/`
3. Practice basic joins in `JOINs/`

### For Intermediate Users
1. Master subqueries in `Subqueries/`
2. Understand performance optimization in `Indexing_Performance/`
3. Learn advanced join techniques in `JOINs/`

### For Advanced Users
1. Explore complex views and stored procedures
2. Master transactions and triggers
3. Dive into advanced date and string functions

## 📊 Query Highlights

### Must-Know Queries
- **Query 37**: SELF JOIN for employee-manager relationships
- **Query 50**: JOIN with complex aggregations
- **Query 57**: Correlated subquery for nth highest salary

### Performance-Focused Queries
- **Query 86**: EXPLAIN for query execution plan
- **Query 102**: Performance monitoring with performance_schema
- **Query 110**: Bulk insert optimization techniques

### Real-World Scenarios
- **Query 24**: Customer lifetime value calculation
- **Query 135**: Order processing with transaction management
- **Query 207**: Customer churn prediction analysis

## 🛠️ MySQL Version Requirements

- **Basic queries**: MySQL 5.6+
- **JSON functions**: MySQL 5.7+
- **Advanced functions**: MySQL 8.0+ recommended

## 📝 Tips for Usage

1. **Read comments**: Each query has detailed explanations
2. **Modify and experiment**: Change parameters to see different results
3. **Check execution plans**: Use EXPLAIN for performance analysis
4. **Build incrementally**: Start with simple queries and add complexity
5. **Test with sample data**: Use the provided sample data for consistent results

## 🎓 Interview Preparation

This collection covers common interview topics:

- **SQL Fundamentals**: SELECT, WHERE, ORDER BY, LIMIT
- **Joins and Relationships**: All join types and complex relationships
- **Aggregations**: GROUP BY, HAVING, and aggregate functions
- **Subqueries**: Correlated vs non-correlated subqueries
- **Performance**: Indexing, query optimization, execution plans
- **Advanced Topics**: Transactions, stored procedures, triggers

## 🔧 Customization

Feel free to:
- Add your own queries to existing files
- Create new topic folders
- Modify the database schema for your needs
- Export queries for documentation or presentations

## 📈 Progress Tracking

Use the queries to track your learning progress:
- ✅ Basic queries (1-30)
- ✅ Intermediate queries (31-110)
- ✅ Advanced queries (111-240)

## 🤝 Contributing

This is a comprehensive learning resource. Feel free to:
- Report issues or errors
- Suggest improvements
- Add new query categories
- Share your own optimized solutions

## 📞 Support

For questions or clarifications:
1. Check the query comments for explanations
2. Test queries with the provided sample data
3. Use MySQL documentation for function references
4. Experiment with different parameters and scenarios

---

**Happy Learning! 🎓**

This collection will help you master MySQL from basic operations to advanced features, preparing you for real-world challenges and technical interviews.
