echo PATH = $PATH
echo vessel @ `which vessel`

echo
echo == Build.
echo

dfx start --background
dfx canister create --all
dfx build

echo
echo == Start BigMap service.
echo

dfx canister install BigMap

echo
echo == Test BigMap service.
echo

dfx canister install BigMapPutGet

LOOP="(true)";
while [ "$LOOP" == "(true)" ]; do
    LOOP=$(dfx canister call BigMapPutGet doNextCall)
done

dfx canister call BigMapPutGet getFullLog --output raw > BigMapPutGet.raw

echo BEGIN BigMapPutGet.raw
cat BigMapPutGet.raw
echo END BigMapPutGet.raw

echo BEGIN 'cat .dfx/local/canisters/BigMapPutGet/BigMapPutGet.did'
cat .dfx/local/canisters/BigMapPutGet/BigMapPutGet.did
echo END

echo BEGIN 'didc decode `cat BigMapPutGet.raw` > BigMapPutGet.log'
didc decode `cat BigMapPutGet.raw` -d .dfx/local/canisters/BigMapPutGet/BigMapPutGet.did -m getFullLog > BigMapPutGet.log 
echo END 'didc decode `cat BigMapPutGet.raw`'

echo BEGIN "BigMapPutGet.log (latest-captured log)"
cat BigMapPutGet.log
echo END "BigMapPutGet.log"

echo BEGIN "test/BigMapPutGet.log (expected log)"
cat test/BigMapPutGet.log
echo END "test/BigMapPutGet.log"

echo BEGIN "didc diff compares a expected log (left) and latest captured log (right):"
didc diff "`cat test/BigMapPutGet.log`" "`cat BigMapPutGet.log`"
echo END candiff comparison.

# to do for candiff -- fix this so that it works (under some flags?) like `didc diff` above.
#
# echo BEGIN "candiff compares a expected log (left) and latest captured log (right):"
# candiff diff "`cat test/BigMapPutGet.log`" "`cat BigMapPutGet.log`"
# echo END candiff comparison.
