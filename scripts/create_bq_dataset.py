from google.cloud import bigquery

from scripts.config import GCP_PROJECT_ID, BQ_DATASET


def main() -> None:
    """Create BigQuery dataset if it does not exist."""
    if not GCP_PROJECT_ID:
        raise RuntimeError("Missing GCP_PROJECT_ID")

    client = bigquery.Client(project=GCP_PROJECT_ID)

    dataset_id = f"{GCP_PROJECT_ID}.{BQ_DATASET}"
    dataset = bigquery.Dataset(dataset_id)
    dataset.location = "US"

    dataset = client.create_dataset(dataset, exists_ok=True)

    print(f"[+] Dataset ready: {dataset.full_dataset_id}")


if __name__ == "__main__":
    main()