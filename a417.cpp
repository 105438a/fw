//
//  aaaa.cpp
//  zerojudge
//
//  Created by nnaaaaa on 2022/4/15.
//

#include <iostream>
using namespace std;
int main(int argc, const char * argv[]){
    int t,n,m;
    cin>>t;
    for(int i=0;i<t;i++){
        cin>>n>>m;
        int **num= new int * [n]();
        for(int i=0;i<n;i++)
            num[i]= new int[n]();
            for(int i=0;i<n;i++)
                num[0][i]=i+1;
            for(int i=0,j=n-1,k=n+1,count1=n-1,count2=1,count3=1,regular=1;k<=n*n;k++){
                if(count2>count1){
                    regular++;
                    count2=1;
                    count3++;
                }
                if(count3>2){
                    count1--;
                    count3=1;
                }
                if(regular%4==1)
                    i++;
                else if(regular%4==2)
                    j--;
                else if(regular%4==3)
                    i--;
                else if(regular%4==0)
                    j++;
                num[i][j]=k;
                count2++;
            }
        for(int i=0;i<n;i++){
            for(int j=0;j<n;j++){
                if(m==1)
                    printf("%5d",num[i][j]);
                else
                    printf("%5d",num[j][i]);
            }
            printf("\n");
        }
        delete []num;
    }
    
    
    return 0;
}
