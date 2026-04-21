# Testing Patterns

**Analysis Date:** 2026-04-21

## Project Status

This is an early-stage project with no source code or tests yet. The patterns below are **recommendations** based on the declared stack (Python, PostgreSQL, pandas, SQLAlchemy) and standard practices for data/analytics projects.

## Test Framework

**Recommended Runner:**
- pytest (latest version)
- Config: `pytest.ini` or `pyproject.toml`

**Assertion Library:**
- pytest built-in assertions
- pandas.testing for DataFrame comparisons

**Recommended dependencies to add to `requirements.txt`:**
```
pytest>=8.0.0
pytest-cov>=4.0.0
pytest-mock>=3.0.0
```

**Run Commands:**
```bash
pytest                    # Run all tests
pytest -v                 # Verbose output
pytest --cov=scripts      # With coverage
pytest -k "test_revenue"  # Run specific tests
pytest -x                 # Stop on first failure
```

## Test File Organization

**Location:**
- Co-located with source: `scripts/test_*.py`
- Or separate directory: `tests/` at project root

**Recommended structure:**
```
nusacommerce-analytics/
├── scripts/
│   ├── generate_data.py
│   └── test_generate_data.py    # Co-located
├── tests/                        # Or separate
│   ├── conftest.py              # Shared fixtures
│   ├── test_data_generation.py
│   ├── test_transformations.py
│   └── test_sql_queries.py
```

**Naming:**
- Test files: `test_<module_name>.py`
- Test functions: `test_<function_name>_<scenario>()`

## Test Structure

**Suite Organization:**
```python
import pytest
import pandas as pd
from scripts.transformations import calculate_revenue

class TestCalculateRevenue:
    """Tests for the calculate_revenue function."""
    
    def test_calculate_revenue_with_valid_data(self, sample_orders_df):
        """Revenue calculation with standard order data."""
        result = calculate_revenue(sample_orders_df)
        assert result == pytest.approx(1500.00, rel=1e-2)
    
    def test_calculate_revenue_empty_dataframe(self):
        """Revenue should be zero for empty DataFrame."""
        empty_df = pd.DataFrame(columns=['order_id', 'total'])
        result = calculate_revenue(empty_df)
        assert result == 0.0
    
    def test_calculate_revenue_with_refunds(self, orders_with_refunds_df):
        """Revenue calculation should handle negative values."""
        result = calculate_revenue(orders_with_refunds_df)
        assert result == pytest.approx(1200.00, rel=1e-2)
```

**Patterns:**
- Use class grouping for related tests
- Descriptive function names that explain the scenario
- One assertion per test (preferred) or closely related assertions

## Mocking

**Framework:** pytest-mock (pytest fixture: `mocker`)

**Database mocking pattern:**
```python
import pytest
from unittest.mock import MagicMock
from sqlalchemy import create_engine

def test_load_orders_from_db(mocker):
    """Test loading orders without actual database connection."""
    mock_engine = mocker.patch('scripts.data_loader.create_engine')
    mock_connection = MagicMock()
    mock_engine.return_value.connect.return_value.__enter__.return_value = mock_connection
    
    # Configure mock to return test data
    mock_connection.execute.return_value.fetchall.return_value = [
        (1, 'Order1', 100.00),
        (2, 'Order2', 200.00),
    ]
    
    from scripts.data_loader import load_orders
    result = load_orders()
    
    assert len(result) == 2
    mock_engine.assert_called_once()
```

**External API mocking (for gspread):**
```python
def test_export_to_sheets(mocker):
    """Test Google Sheets export without real API calls."""
    mock_gspread = mocker.patch('scripts.export.gspread')
    mock_client = MagicMock()
    mock_gspread.service_account.return_value = mock_client
    
    from scripts.export import export_to_sheets
    export_to_sheets(sample_df, 'Sheet1')
    
    mock_client.open.assert_called_once()
```

**What to Mock:**
- Database connections
- External API calls (Google Sheets, Kaggle)
- File system operations (when testing logic, not I/O)
- Current datetime (for reproducible tests)

**What NOT to Mock:**
- pandas DataFrame operations
- Pure transformation functions
- Data validation logic

## Fixtures and Factories

**Shared fixtures in `conftest.py`:**
```python
import pytest
import pandas as pd
from faker import Faker

@pytest.fixture
def fake():
    """Seeded Faker instance for reproducible test data."""
    fake = Faker('id_ID')  # Indonesian locale
    fake.seed_instance(42)
    return fake

@pytest.fixture
def sample_orders_df():
    """Small orders DataFrame for unit tests."""
    return pd.DataFrame({
        'order_id': [1, 2, 3],
        'customer_id': [101, 102, 101],
        'total': [500.00, 750.00, 250.00],
        'order_date': pd.to_datetime(['2024-01-15', '2024-01-16', '2024-01-17']),
        'status': ['completed', 'completed', 'completed'],
    })

@pytest.fixture
def sample_customers_df():
    """Small customers DataFrame for unit tests."""
    return pd.DataFrame({
        'customer_id': [101, 102, 103],
        'name': ['Customer A', 'Customer B', 'Customer C'],
        'city': ['Jakarta', 'Surabaya', 'Bandung'],
        'registration_date': pd.to_datetime(['2023-06-01', '2023-07-15', '2023-08-20']),
    })

@pytest.fixture
def orders_with_refunds_df():
    """Orders including refunds (negative totals)."""
    return pd.DataFrame({
        'order_id': [1, 2, 3, 4],
        'total': [500.00, 750.00, 250.00, -300.00],  # Refund
        'status': ['completed', 'completed', 'completed', 'refunded'],
    })
```

**Factory pattern for complex data:**
```python
@pytest.fixture
def order_factory(fake):
    """Factory to generate order records."""
    def _create_order(
        order_id: int = None,
        customer_id: int = None,
        total: float = None,
        **kwargs
    ):
        return {
            'order_id': order_id or fake.random_int(1, 10000),
            'customer_id': customer_id or fake.random_int(1, 1000),
            'total': total or fake.pyfloat(min_value=10, max_value=5000, right_digits=2),
            'order_date': fake.date_between(start_date='-2y', end_date='today'),
            **kwargs
        }
    return _create_order
```

**Location:**
- Project-wide fixtures: `tests/conftest.py`
- Module-specific fixtures: in the test file itself

## Coverage

**Requirements:** Not enforced - recommend 80% minimum for core logic

**Configuration in `pyproject.toml`:**
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --cov=scripts --cov-report=term-missing"

[tool.coverage.run]
source = ["scripts"]
omit = ["*/__pycache__/*", "*/test_*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.:",
]
```

**View Coverage:**
```bash
pytest --cov=scripts --cov-report=html
open htmlcov/index.html
```

## Test Types

**Unit Tests:**
- Scope: Individual functions, data transformations
- Location: `tests/unit/` or co-located with source
- Fast, no external dependencies

**Integration Tests:**
- Scope: Database interactions, end-to-end data pipelines
- Location: `tests/integration/`
- May require test database setup

**SQL Tests:**
- Use dbt for SQL testing (if added later)
- Or validate SQL output with pandas assertions

## Common Patterns

**DataFrame equality testing:**
```python
import pandas as pd
from pandas.testing import assert_frame_equal

def test_transform_orders(sample_orders_df):
    """Test order transformation produces expected output."""
    expected = pd.DataFrame({
        'customer_id': [101, 102],
        'total_orders': [2, 1],
        'total_revenue': [750.00, 750.00],
    })
    
    result = transform_orders(sample_orders_df)
    
    assert_frame_equal(
        result.reset_index(drop=True),
        expected.reset_index(drop=True),
        check_dtype=False  # Allow float64 vs int64
    )
```

**Async testing (if needed):**
```python
import pytest

@pytest.mark.asyncio
async def test_async_data_fetch():
    """Test async data fetching operation."""
    result = await fetch_data_async()
    assert len(result) > 0
```

**Parameterized testing:**
```python
import pytest

@pytest.mark.parametrize("month,expected_revenue", [
    (1, 15000.00),
    (2, 12500.00),
    (3, 18750.00),
])
def test_monthly_revenue(sample_yearly_data, month, expected_revenue):
    """Test revenue calculation for different months."""
    result = calculate_monthly_revenue(sample_yearly_data, month)
    assert result == pytest.approx(expected_revenue, rel=0.01)
```

**Error testing:**
```python
import pytest

def test_calculate_revenue_invalid_column():
    """Test that missing column raises KeyError."""
    bad_df = pd.DataFrame({'wrong_column': [1, 2, 3]})
    
    with pytest.raises(KeyError, match="total"):
        calculate_revenue(bad_df)

def test_database_connection_failure(mocker):
    """Test graceful handling of database connection errors."""
    mocker.patch('scripts.db.create_engine', side_effect=ConnectionError("DB unavailable"))
    
    with pytest.raises(ConnectionError):
        from scripts.db import connect
        connect()
```

**Temporary files and databases:**
```python
import pytest
import tempfile
from pathlib import Path

@pytest.fixture
def temp_csv(tmp_path):
    """Create a temporary CSV file for testing."""
    csv_path = tmp_path / "test_data.csv"
    csv_path.write_text("id,name,value\n1,A,100\n2,B,200\n")
    return csv_path

def test_load_csv(temp_csv):
    """Test loading CSV from file path."""
    result = load_csv(temp_csv)
    assert len(result) == 2
```

---

*Testing analysis: 2026-04-21*
*Note: This project has no tests yet. Apply these patterns as code is added.*
