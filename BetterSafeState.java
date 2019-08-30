import java.util.concurrent.atomic.AtomicIntegerArray;
import java.util.concurrent.locks.ReentrantLock;

class BetterSafeState implements State {
    private byte[] value;
    private byte maxval;
    private final ReentrantLock rlock = new ReentrantLock();

    BetterSafeState(byte[] v) { value = v; maxval = 127; }

    BetterSafeState(byte[] v, byte m) { value = v; maxval = m; }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public AtomicIntegerArray currentarr() {
        return null;
    }

    public boolean swap(int i, int j) {

        rlock.lock();

        if (value[i] <= 0 || value[j] >= maxval) {

            rlock.unlock();
            return false;
        }

        value[i]--;
        value[j]++;

        rlock.unlock();

        return true;
    }
}