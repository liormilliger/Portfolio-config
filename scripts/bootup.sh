#/bin/bash

echo "----====~~~~ {{{[[[<<< BOOTING ALL SCRIPTS >>>]]]}}}"
echo ""
echo ""
sh ./scripts/app_and_ingress.sh

sh ./scripts/storage.sh

sh ./scripts/install_efk.sh

sh ./scripts/prom_stack.sh