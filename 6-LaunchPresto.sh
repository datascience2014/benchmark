# Creates a small dataproc cluster for benchmarking
# Be sure to delete the cluster created in 1-LaunchDataproc.sh before running this
set -e

# Create master instance
gcloud compute \
      --project "digital-arbor-400" \
      instances create "tpcds-presto-m" \
      --zone "us-central1-f" \
      --machine-type "n2-standard-8" \
      --image-project "ubuntu-os-cloud" \
      --image "ubuntu-1804-bionic-v20200129a" \
      --metadata "PrestoRole=Master,PrestoMaster=tpcds-presto-m" \
      --metadata-from-file "startup-script=Presto.sh" \
      --boot-disk-size "10" \
      --local-ssd interface=nvme

# Create worker instance group
gcloud compute instance-templates delete "presto-worker" \
      --quiet \
      || echo "...ignoring error"
gcloud compute \
      --project "digital-arbor-400" \
      instance-templates create "presto-worker" \
      --machine-type "n2-standard-8" \
      --image-project "ubuntu-os-cloud" \
      --image "ubuntu-1804-bionic-v20200129a" \
      --metadata "PrestoRole=Worker,PrestoMaster=tpcds-presto-m" \
      --metadata-from-file "startup-script=Presto.sh" \
      --boot-disk-size "10" \
      --local-ssd interface=nvme
gcloud compute \
      --project "digital-arbor-400" \
      instance-groups managed create "tpcds-presto-w" \
      --zone "us-central1-f" \
      --base-instance-name "tpcds-presto-w" \
      --template "presto-worker" \
      --size "31"