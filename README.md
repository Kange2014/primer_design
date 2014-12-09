primer_design
=============


4	1.	安装
5	本工具可以在大多数Unix系统如Linux机器上安装运行，同时Windows系统机器上也同样可以安装运行。不过，运行前都需要确保Perl已经正确安装在相应的系统上。本工具包解压缩后即可使用。但在成功使用本工具前，还需正确安装以下软件：
6	1.1	Primer3
7	Primer3是一个可以批量设计PCR引物、杂交探针、测序引物的工具，可本地安装或在线使用。本地安装版本支持各种操作系统如Windows、Linux、Mac等，但建议下载primer3发布版本1使用。其中Windows或Linux或Mac版本可在http://sourceforge.net/projects/primer3/files/primer3/1.1.4/处下载，linux下安装方法大致如下：
8	
9	> unzip primer3-<release>.tar.gz
10	> tar xvf primer3-<release>.tar
11	> cd primer3-<release>/src
12	> make all
13	> make test
14	
15	成功安装后，应该会生成一个名为primer3_core的可执行文件，亦即Primer3的默认软件名，另外默认安装路径为/user/bin/，如果不是，可以通过相应参数对其进行修改（见下文）。其他版本安装具体可参考primer3帮助文档。
16	1.2	BLAST
17	在生物信息学中，BLAST（Basic Local Alignment Search Tool）它是一个用来比对生物序列的一级结构（如不同蛋白质的氨基酸序列或不同基因的DNA序列）的算法。已知一个包含若干序列的数据库，BLAST可以让研究者在其中寻找与其感兴趣的序列相同或类似的序列。BLAST可在美国国家生物技术信息中心（NCBI）官方地址ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/ 处选择最新的版本下载。针对不同的操作系统，用户可下载相应的软件包，如blast-2.2.26-x64-linux.tar.gz即是版本2.2.26下的64位Linux系统的BLAST软件包。Linux下BLAST的安装方式如下：
18	a)	把BLAST的压缩文件解压；
19	b)	在当前用户目录下，编辑.bashrc文件，在文件中加入包含BLAST可执行文件的路径，如：
20	export PATH=/home/username/blast/bin/:$PATH;
21	其他版本安装可参考相应的BLAST帮助文档。
22	1.3	Bioperl
23	Bioperl 是 Perl 语言专门用于生物信息的工具与函数模块集，致力于集成生物信息学、基因组学和生命科学研究的开发源码。不同操作系统下的安装，可参照http://www.bioperl.org/wiki/Installing_BioPerl中的说明。这里，简要叙述Linux下的一种安装方法：
24	a)	下载最新的bioperl版本，如BioPerl-1.6.1.tar.gz：http://bioperl.org/DIST/；
25	b)	解压：
26	> tar xvfz BioPerl-1.6.1.tar.gz
27	> cd BioPerl-1.6.1
28	c)	运行Build.PL安装：
29	> perl Build.PL
30	> ./Build test
31		注意，无需担心部分tests未能通过，在超过12000个tests中少数失败并不会影响Bioperl的使用。
32			>./Build install
33	如果没有root权限，可选择可写入的安装路径：
34	> perl Build.PL --install_base /home/users/dag
35	> ./Build test
36	> ./Build install
37	这告知perl安装Bioperl的各部分模块到/home/users/dag 下，并在该目录下创建一些新的子目录，如
38	  		/home/users/dag/lib/perl5/Bio/
39	然后，在Bioperl脚本中，需要加入这样一行代码：
40	use lib "/home/users/dag/lib/perl5/";
41	告诉脚本Bioperl在该目录下。
42	1.4	Text::CSV、Clone等模块
43	可从CPAN中下载Text::CSV、Clone等模块，可解压后直接拷贝Text文件夹以及Clone.pm到相应的路径下，如“/home/users/dag/lib/perl5/”。
44	2.	运行
45	2.1	设计引物
46	> perl primer_design.pl <sequence_fasta_file> <output_file_name>
47	<sequence_fasta_file>: 引物设计时所需的参照序列文件名，可包含多条序列；
48	<output_file_name>： 设计得到的引物结果文件名；
49	
50	由于设计引物时，相关的参数众多，故而用户可以基于如下的代码来查看其他参数及其含义：
51	
52	my $args = $primer3->arguments;
53	print "ARGUMENT\tMEANING\n";
54	foreach my $key (keys %{$args}) {print "$key\t", $$args{$key}, "\n"}
55	
56	去除primer_design.pl脚本中相应代码行前的注释符号“#”即可。
57	其中，对于引物设计过程中，常见的参数，设置方式如下（同上，去除去除primer_design.pl脚本中相应代码行前的注释符号“#”即可）：
58	
59	# 设定需要设计的引物对的数目，比如50对
60	$primerobj->add_targets(PRIMER_NUM_RETURN=>"50"); 
61	
62	# 设定引物产物覆盖的区域
63	# If one or more targets is specified then a legal primer pair must flank at least one of them
64	# TRAGET: (interval list, default empty) Regions that must be included in the product. 
65	# The value should be a space-separated list of <start>,<length>     
66	 $primerobj->add_targets(TARGET => 500,400); 
67	
68	# 设定引物的最大最小Tm
69	$primerobj->add_targets(PRIMER_OPT_TM=>"55");
70	$primerobj->add_targets(PRIMER_MIN_TM=>"50");
71	$primerobj->add_targets(PRIMER_MAX_TM=>"60");
72		
73	# 设定引物产物的大小
74	$primerobj->add_targets(PRIMER_PRODUCT_SIZE_RANGE => "100-300");
75		
76	# 设定引物序列的长短
77	$primerobj->add_targets(PRIMER_OPT_SIZE=>"21");
78	$primerobj->add_targets(PRIMER_MIN_SIZE=>"18");
79	 	$primerobj->add_targets(PRIMER_MAX_SIZE=>"25");
80		
81	此外，如果Primer3的软件名不是默认的primer3_core，可通过如下的方式修改：
82	$primer3->program_name('my_suprefast_primer3');
83	unless ($primer3->executable) {
84	 	print STDERR "primer3 can not be found. Is it installed?\n";
85	 	exit(-1)
86	}
87	或者，Primer3的安装路径不是在默认的/usr/bin/ primer3_core，需要进行更改：
88	$primerobj = Design->new(-seq => $seq_ref, -path => /home/usrname/primer3/primer3_core);
89	2.2	引物保守性打分
90	> perl primer_score.pl <primer_CSV_file> <database_file> <output_file_name>
91	<primer_CSV_file>：即primer_design.pl脚本生成的引物结果文件，以CSV格式存放；
92	<database_file>：引物保守性打分所依赖的数据库文件。该文件可从NCBI数据库下载。
93	
94	例如，对于甲型流感病毒HA基因，利用primer_design.pl脚本设计得到相应的引物序列后，可从NCBI旗下的流感数据库下载得到大量甲型流感病毒HA序列（http://www.ncbi.nlm.nih.gov/genomes/FLU/Database/nph-select.cgi?go=database），作为引物保守性评估的参考数据库文件；又如，对于肠道病毒ev71（Human enterovirus 71） VP1基因，可先通过NCBI Taxonomy查询得到其对应的taxonomy ID为39054 ，然后在NCBI nucleotide数据库输入“txid39054[Organism:exp]”查询，并进一步在Advanced搜索中，选择Gene Name为VP1，或者直接在nucleotide数据库输入“(txid39054[Organism:exp]) AND VP1[Gene Name]”，查询便可得到当前数据库中所有与Human enterovirus 71 VP1基因有关的核酸序列片段，下载这些序列并以FASTA格式保存即可。建议文件名中不要有空格出现。
95	
96	<output_file_name>：引物打分结果文件，其格式如下（可用windows office excel打开）：
97	 
98	其中第一列是设计引物时所用参考序列的Genbank ID，最后一列是引物的保守性分值。分值越高表示该引物片段在所得到的样本序列中越保守，也越适合作扩增用引物。另外，在同等分值的情况下，推荐使用从上往下排序靠前的引物对。
99	
100	3. Specificity
101	>perl primer_specificity.pl <primer_score_CSV_file> <database_file> <output_file_name>
102	< primer_score_CSV_file>: file by primer_score.pl
103	<database_file>: background database for evaluating primers’ specificity
