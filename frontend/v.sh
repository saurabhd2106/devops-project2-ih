# =========[ setup ]=========
RG="rg-dev-Abdullah-Alotaibi"
FE="acafe-dev"   # frontend
BE="acabe-dev"   # backend
TAIL=200

# =========[ revisions ]=========
FE_REV=$(az containerapp revision list -g "$RG" -n "$FE" --query "[-1].name" -o tsv)
BE_REV=$(az containerapp revision list -g "$RG" -n "$BE" --query "[-1].name" -o tsv)

# =========[ images running now (اختياري مفيد) ]=========
echo -e "\n=== Running images ==="
az containerapp show -g "$RG" -n "$FE" --query "properties.template.containers[].{name:name,image:image}" -o table
az containerapp show -g "$RG" -n "$BE" --query "properties.template.containers[].{name:name,image:image}" -o table

# =========[ logs: application ]=========
echo -e "\n=== Frontend app logs ($FE:$FE_REV) ==="
az containerapp logs show -g "$RG" -n "$FE" --revision "$FE_REV" --tail $TAIL

echo -e "\n=== Backend app logs ($BE:$BE_REV) ==="
az containerapp logs show -g "$RG" -n "$BE" --revision "$BE_REV" --tail $TAIL

# =========[ logs: system ]=========
echo -e "\n=== Frontend system logs ==="
az containerapp logs show -g "$RG" -n "$FE" --type system --tail $TAIL

echo -e "\n=== Backend system logs ==="
az containerapp logs show -g "$RG" -n "$BE" --type system --tail $TAIL

# =========[ health via AGW ]=========
echo -e "\n=== Backend health via AGW ==="
PIP=$(az network public-ip show -g "$RG" -n pip-agw-dev --query ipAddress -o tsv)
curl -s "http://$PIP/api/health" || true

echo -e "\n=== Done ==="

