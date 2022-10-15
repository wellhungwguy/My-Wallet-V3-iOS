#  scripts/bootstrap.sh
#
#  What It Does
#  ------------
#  - Runs carthage, recaptcha integration, generates the project and opens it.
# 

set -ue

if [ ! -f ".env" ]; then
	echo "renaming .env.default to .env"
	cp .env.default .env
fi

git config blame.ignoreRevsFile .git-blame-ignore-revs

if [[ -z ${IS_CI+x} ]]; then
	HOMEBREW_NO_AUTO_UPDATE=1 brew bundle
fi

echo "Running Carthage"
for i in 1 2 3; do 
  sh scripts/carthage-bootstrap.sh && break || sleep 2
  echo "Retry running Carthage"
done

echo "Running Recaptcha"
sh ./scripts/recaptcha.sh

echo "Generating project"
sh ./scripts/generate_projects.sh
