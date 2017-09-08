---
title: 几种基本排序算法
date: 2017-08-25 09:59:34
tags: [算法]
---

## 冒泡排序

### 基本原理
每一轮从头开始两两比较，将较大的项放在较小项的右边，这样每轮下来保证该轮最大的数在最右边。

<!-- more -->

### 算法实现
```java
public static void bubbleSort(int[] source) {
        for(int i = source.length - 1; i > 0; i--) {
            for(int j = 0; j < i; j ++) {
                if(source[j] > source[j+1]) {
                    swap(source, j, j + 1);
                }
            }
        }
    }
```

### 算法示例

待排序
```
13 6 29 3
```

排序过程
```
1:6 13 3 29 //13和6，交换；13和29，不交换；29和3，交换
2:6 3 13 29 //6和13，不交换；13和3，交换
3:3 6 13 29 //6和3，交换
```

冒泡排序算法还有个可以改进的地方，就是在算法中加入一个布尔变量标识该轮有没有进行数据的交换，若在某一次排序中未发现气泡位置的交换，则说明待排序的无序区中所有的项均已满足排序后的结果。

```java
public static void bubbleSort(int[] source) {
        for(int i = source.length - 1; i > 0; i--) {
            boolean exchange = false;
            for(int j = 0; j < i; j ++) {
                if(source[j] > source[j+1]) {
                    swap(source, j, j + 1);
                    exchange = true;
                }
            }
            if(!exchange) return;
        }
    }
```

### 算法分析
- 时间复杂度：冒泡排序最好的情况是初始状态是正序的，一次扫描即可完成排序，所以最好的时间复杂度为O(N)；最坏的情况是反序的，此时最坏的时间复杂度为O(N2)。平均情况，每轮N/2次循环，N轮时间复杂度为O(N2)。
- 稳定性：算法是稳定的，因为当a=b时，由于只有大于才做交换，故a和b的位置没有机会交换，所以算法稳定。
- 空间复杂度：空间复杂度为O(1)，不需要额外空间。

## 选择排序

### 基本原理
选择排序改进了冒泡排序，将必要的交换次数从O(n2)减少到O(n)，但是比较次数仍保持为O(n2)。冒泡排序每比较一次就可能交换一次，但是选择排序是将一轮比较完后，把最小的放到最前的位置（或者把最大的放到最后）。

### 算法实现

```java
public static void selectSort(int[] source) {
        int min;
        for(int i = 0; i < source.length - 1; i++) {
            min = i;
            for(int j = i + 1; j < source.length; j++) {
                if(source[j] <source[min])
                    min = j;
            }
            swap(source, i, min);
        }
    }
```

### 算法示例

待排序
```
13 6 29 3
```

排序过程
```
1:3 6 29 13 //第一遍，3最小，13和3交换
2:3 6 29 13 //第二遍，6最小，不需要交换
3:3 6 13 29 //第三遍，13最小，交换
```

### 算法分析
- 时间复杂度：选择排序最好和最坏的情况一样运行了O(N2)时间，但是选择排序无疑更快，因为它进行的交换少得多，当N值较小时，特别是如果交换时间比比较时间大得多时，选择排序实际上是相当快的。平均复杂度也是O(N2)。
- 稳定性：算法是不稳定的，假设a=b，且a在b前面，而某轮循环中最小值在b后面，而次最小值需要跟a交换，这时候b就在a前面了，所以选择排序是不稳定的。
- 空间复杂度：空间复杂度为O(1)，不需要额外的空间。

## 插入排序

### 基本原理
插入排序的实现步骤为：从第一个元素开始，该元素可以认为已经被排序 -> 取出下一个元素，在已经排序的元素序列中从后向前扫描 -> 如果该元素小于前一个元素，则将两者调换，再与前一个元素比较–> 重复第三步，直到找到已排序的元素小于或者等于新元素的位置 -> 将新元素插入到该位置中 -> 重复第二步

### 算法实现

```java
public static void insertSort(int[] source) {
        for(int i = 1; i < source.length; i++) {
            for(int j = i; (j > 0) && (source[j] < source[j-1]); j--) {
                swap(source, j, j-1);
            }
            sortNum ++;
            print(true);
        }
    }
```

### 算法示例

待排序
```
13 6 29 3
```

排序过程
```
1:6 13 29 3 //第一遍，位置2开始，13比6大，不需要交换
2:6 13 29 3 //第二遍，29分别比13和6大，不需要交换
3:3 6 13 29 //第三遍，3比29小，交换；3比13小，交换；3比6小，交换
```

### 算法分析
- 时间复杂度：插入排序最好的情况是序列已经是升序排列了，在这种情况下，需要进行N-1次比较即可，时间复杂度为O(N)，最坏的情况是序列降序排列，这时候时间复杂度为O(N2)。因此插入排序不适合对于数据量比较大的排序应用。但是如果需要排序的数据量很小(如小于千)，那么插入排序还是一个不错的选择。插入排序平均时间复杂度为O(N2)，但是它要比冒泡排序快一倍，比选择排序还要快一点，经常被用在较复杂的排序算法的最后阶段，例如快速排序。
- 稳定性：算法是稳定的，假设a=b，且a在b的前面，其排序位置必然比b先确定，而后面再插入b时，必然在a的后面，所以是稳定的。
- 空间复杂度：空间复杂度为O(1)，不需要额外的空间。

注：冒泡最大的，选择最小的，插入到已排好序的

## 希尔排序

### 基本原理

希尔排序是基于插入排序的，插入排序有个弊端，假设一个很小的数据项在很靠近右端的位置上，那么所有的中间数据项都必须向右移动一位，这个步骤对每一个数据项都执行了将近N次的复制，这也是插入排序效率为O(N2)的原因。

希尔排序的中心思想是将数据进行分组，然后对每一组数据进行插入排序，在每一组数据都有序后，再对所有的分组利用插入排序进行最后一次排序。这样可以显著减少数据交换的次数，以达到加快排序速度的目的。

### 算法实现

```java
public static void shellSort(int[] source) {
        int h = 1;
        int nElem = source.length;
        while(h <= nElem / 2) {
            h = h * 2 + 1;
        }

        while(h > 0) {
            for(int i = h; i < nElem; i++) {
                //insert sort
                for(int j = i; j < nElem; j += h) {
                    for(int k = j; (k - h >= 0) && source[k] < source[k - h]; k -= h) {
                        swap(source, k, k - h);
                    }
                }
            }
            h = (h-1)/2;
        }
    }
```

这种思想需要依赖一个增量序列，我们称为n-增量，n表示进行排序时数据项之间的间隔，习惯上用h表示。增量序列在希尔排序中是很重要的。一般好的增量序列都有2个共同的特征： 最后一个增量必须为1，保证最后一趟是一次普通的插入排序；应该尽量避免序列中的值（尤其是相邻的值）互为倍数的情况

### 算法示例

待排序
```
13 6 29 3 38
```

排序过程，这里选取的间隔为3和1
```
1:3 6 29 13 38 // 间隔为3，13和3，交换
2:3 6 29 13 38 // 间隔为3，6和38不交换
3:3 6 29 13 38 // 间隔为1，3和6不交换
4:3 6 29 13 38 // 间隔为1，29用插入排序比6，3都大，不交换
5:3 6 13 29 38 // 间隔为1，13通过插入排序和29交换，后面都类普通插入排序，省略
...
```

### 算法分析

- 时间复杂度：希尔排序时间复杂度平均为O(NlogN)，最好与最坏情况要根据具体的增量序列来判断，对于不同的增量序列有不同的复杂度。希尔排序的性能优于直接插入排序，因为在希尔排序开始时增量较大，分组较多，每组的记录数目少，故各组内直接插入较快，后来随着增量逐渐缩小，分组数逐渐减少，而各组的记录数目逐渐增多，但是由于已经局部排过序了，所以已经接近有序状态，新的一趟排序过程也较快。因此，希尔排序在效率上较直接插入排序有较大的改进。
- 稳定性：希尔排序是不稳定的，因为不同的间隔对应的数据是独自比较的，如果a=b，但是不在同一个间隔上，显然会出现前后颠倒的情况，所以希尔排序是不稳定的。
- 空间复杂度： 空间复杂度为O(1)，不需要额外的存储空间。

## 快速排序

### 基本原理

快速排序本质上通过一个数组划分为两个子数组，然后递归地调用自身为每一个子数组进行快速排序来实现的，即算法分为三步：
1. 把数组或者子数组划分为左边（较小的关键字）的一组和右边（较大的关键字）的一组；
2. 调用自身对左边的一组进行排序；
3. 调用自身对右边的一组进行排序。

快速排序需要划分数组，这就用到了划分算法。划分算法是由两个指针开始工作，两个指针分别指向数组的两头，左边的指针leftPtr向右移动，右边的指针rightPtr向左移动。当leftPtr遇到比枢纽（待比较的数据项，比其小的在其左边，比其大的在其右边，下面均称之为“枢纽”）小的数据项时继续右移，当遇到比枢纽大的数据项时就停下来；类似的rightPtr想反。两边都停下后，leftPtr和rightPtr都指在数组的错误一方的位置的数据项，交换这两个数据项。交换后继续移动这两个指针。

### 算法实现

```java
public static void quickSort(int[] a) {
        recQuickSort(a,0, a.length-1);
    }

    public static void recQuickSort(int[] a, int left, int right) {
        if(right-left <= 0) {
            return;
        }
        else {
            int pivot = a[right]; //保存最右边的值，以这个值作为划分点
            int partition = partitionIt(a,left, right, pivot);//将数组划分两部分，并将划分点的值放在正确位置，并返回该位置
            recQuickSort(a, left, partition-1);//调用自身对左边进行排序
            recQuickSort(a, partition+1, right);//调用自身对右边进行排序
        }
    }

    public static int partitionIt(int[] a, int left, int right, int pivot) {
        int leftPtr = left - 1;
        int rightPtr = right;
        while(true) {
            while(a[++leftPtr] < pivot){} //从左到右，找比待比较大的
            while(rightPtr > 0 && a[--rightPtr] > pivot){} //从右到左，找比待比较的小的
            if(leftPtr >= rightPtr) break;
            else {
                Logs.info(a[leftPtr] + " " + a[rightPtr]);
                swap(a, leftPtr, rightPtr);
            }
        }
        Logs.info(a[leftPtr] + " " + a[right]);
        swap(a, leftPtr, right);//将划分放在正确的位置
        print(true);
        return leftPtr;//返回划分点，用于再次小范围划分
    }
```

### 算法示例

待比较
```
source = {13,6,29, 3, 15}
```

排序过程
```
1:13 6 3 15 29 // 左边比15大的为29，右边比15小的为3，29和3，交换；重复，直到左右位置相同，记录位置
2:3 6 13 15 29 // 上一步中位置3为中间位置，13,6,3，重复上面步骤
3:3 6 13 15 29 // 右边15,19 重复第一步
```

### 算法分析

- 时间复杂度：平均时间复杂度为O(NlogN)，最坏的情况下退化成插入排序了，为O(N2)。
- 稳定性：不稳定的排序方法。
- 空间复杂度：空间复杂度平均为O(logN)，空间复杂度主要是由于递归造成的。

## 归并排序

### 基本原理

 归并排序的思想是把一个数组分成两半，排序每一半。然后用merge方法将数组的两半归并成一个有序的数组。被分的每一半使用递归，再次划分排序，直到得到的子数组只含有一个数据项为止。

### 算法实现

```java
public static void mergeSort(int[] source) {
        int[] workSpace = new int[source.length];
        recMergeSort(source,workSpace, 0, source.length-1);
    }

    private static void recMergeSort(int[] source, int[] workSpace, int lowerBound, int upperBound) {
        if(lowerBound == upperBound) {
            return;
        }
        else {
            int mid = (lowerBound + upperBound) / 2;
            recMergeSort(source, workSpace, lowerBound, mid); //左边排
            recMergeSort(source, workSpace, mid+1, upperBound); //右边排
            merge(source, workSpace, lowerBound, mid+1, upperBound);//归并
            print(true);
        }
    }

    private static void merge(int[] a, int[] workSpace, int lowPtr, int highPtr, int upperBound) {
        int j = 0;
        int lowerBound = lowPtr;
        int mid = highPtr - 1;
        int n = upperBound - lowerBound + 1;
        while(lowPtr <= mid && highPtr <= upperBound) {
            if(a[lowPtr] < a[highPtr]) {
                workSpace[j++] = a[lowPtr++];
            }
            else {
                workSpace[j++] = a[highPtr++];
            }
        }
        while(lowPtr <= mid) {
            workSpace[j++] = a[lowPtr++];
        }

        while(highPtr <= upperBound) {
            workSpace[j++] = a[highPtr++];
        }

        for(j = 0; j < n; j++) {
            a[lowerBound + j] = workSpace[j];
        }
    }
```

### 算法示例

待排序
```
13 6 29 3 15
```

排序过程，先分为两堆，13,6,29一个数组，3,15一个数组；13,6,29再分为，13,6和29
```
1:6 13 29 3 15 // 13和6排序
2:6 13 29 3 15 // 6，13，29排序
3:6 13 29 3 15 // 3，15排序
4:3 6 13 15 29 // 两个数组合并
```

### 算法分析

- 时间复杂度：归并排序的运行时间最差、最好和平均都是O(NlogN)
- 稳定性：归并排序是稳定的，由于没有发生数据交换
- 空间复杂度：空间复杂度为O(N)

## 二叉树排序

### 基本原理

二叉树排序就是利用二叉搜索树的特点进行排序，二叉搜索树的特点是，左子节点比自己小，右子节点比自己大，那么二叉树排序的思想就是先将待排序序列逐个添加到二叉搜索树中去，再通过中序遍历二叉搜索树就可以将数据从小到大取出来。

### 算法实现

```java
class Node {  
    public int value;  
    Node leftChild;  
    Node rightChild;  
    public Node(int val) {  
        value = val;  
    }  
} 

public class Tree2Sort {  
    private Node root;  
    public Tree2Sort() {  
        root = null;  
    }  
    public Node getRoot() {  
        return root;  
    } 
    public void insertSort(int[] source) {  
        for(int i = 0; i < source.length; i++) {  
            int value = source[i];  
            Node node = new Node(value);  
            if(root == null) {  
                root = node;  
            }  
            else {  
                Node current = root;  
                Node parent;  
                boolean insertedOK = false;  
                while(!insertedOK) {  
                    parent = current;  
                    if(value < current.value) {  
                        current = current.leftChild;  
                        if(current == null) {  
                            parent.leftChild = node;  
                            insertedOK = true;  
                        }  
                    }  
                    else {  
                        current = current.rightChild;  
                        if(current == null) {  
                            parent.rightChild = node;  
                            insertedOK = true;  
                        }  
                    }  
                }  
                  
            }  
        }  
    }  
    public void inOrder(Node current) {  
        if(current != null) {  
            inOrder(current.leftChild);  
            System.out.print(current.value + " ");  
            inOrder(current.rightChild);  
        }  
    }  
}  
```

### 算法示例

略

### 算法分析

- 时间复杂度：二叉树的插入时间复杂度为O(logN)，所以二叉树排序算法的时间复杂度为O(NlogN)，
- 稳定性：稳定
- 空间复杂度：空间复杂度为O(N)

## 堆排序

### 基本原理

堆是一个完全二叉树，节点大于或等于自己的子节点。堆排序就是利用完全二叉树的结构将待排序的数据项依次添加到堆中，建立大根堆或者小根堆，从堆中取出的数据项是从大到小或从小到大排列的。因为根节点永远是最大或最小的，而堆中永远是取根节点。

### 算法实现

```java
public class HeapSort {
    private static int[] array;
    private static int currentIndex;
    private static int maxSize;
    public static void setHeapSort(int size) {
        maxSize = size;
        array = new int[maxSize];
        currentIndex = 0;
    }

    public static void insertSort(int[] source) {
        for(int i = 0; i < source.length; i++) {
            array[currentIndex] = source[i]; //插入到节点尾
            tickedUp(currentIndex++); //向上重新排好序，使得满足堆的条件
        }
    }
    private static void tickedUp(int index) {
        int parentIndex = (index - 1) / 2; //父节点的索引
        int temp = array[index]; //将新加的尾节点存在temp中
        while(index > 0 && array[parentIndex] < temp) {
            array[index] = array[parentIndex];
            index = parentIndex;
            parentIndex = (index - 1) / 2;
        }
        array[index] = temp;
    }

    public static int getMax() {
        int maxNum = array[0];
        array[0] = array[--currentIndex];
        trickleDown(0);
        return maxNum;
    }
    private static void trickleDown(int index) {
        int top = array[index];
        int largeChildIndex;
        while(index < currentIndex/2) { //while node has at least one child
            int leftChildIndex = 2 * index + 1;
            int rightChildIndex = leftChildIndex + 1;
            //find larger child
            if(rightChildIndex < currentIndex &&  //rightChild exists?
                    array[leftChildIndex] < array[rightChildIndex]) {
                largeChildIndex = rightChildIndex;
            }
            else {
                largeChildIndex = leftChildIndex;
            }
            if(top >= array[largeChildIndex]) {
                break;
            }
            array[index] = array[largeChildIndex];
            index = largeChildIndex;
        }
        array[index] = top;
    }

    static private int[] source = {13,6,29, 3, 15};
    public static void main(String[] args) {
        setHeapSort(5);
        insertSort(source);
        for (int i = 0; i < maxSize; i ++) {
            Logs.info(getMax());
        }
    }
}

```

### 算法示例

略

### 算法分析

- 时间复杂度：堆中插入和取出的时间复杂度均为O(logN)，所以堆排序算法的时间复杂度为O(NlogN)
- 稳定性：稳定
- 空间复杂度：空间复杂度为O(N)

## 拓扑排序

### 基本原理

基于有向图的排序，见[拓扑排序](http://blog.csdn.net/eson_15/article/details/51194219)


[动图演示](http://www.cs.usfca.edu/~galles/visualization/Algorithms.html)

参考：
[常用数据结构和算法操作效率的对比总结](http://blog.csdn.net/eson_15/article/details/51952328)
