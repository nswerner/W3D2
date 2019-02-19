require_relative 'forum.rb'
require_relative 'question_follow.rb'
require_relative 'question_like.rb'

class User
    attr_accessor :fname, :lname
    attr_reader :id

    def self.all
        data = ForumDBConnection.instance.execute('SELECT * FROM users')
        data.map { |datum| User.new(datum) }
    end 

    def self.find_by_id(id)
        ForumDBConnection.instance.execute(<<-SQL, id)
            SELECT
                 *
            FROM
                users
            WHERE
                users.id = ?
        SQL
    end 

    def self.find_by_name(name) 
        fname, lname = name.split(" ")

        ForumDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT 
                *
            FROM 
                users
            WHERE
                fname = ? AND lname = ?
        SQL
    end 

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def create
        raise "That user already exists" if id

        ForumDBConnection.instance.execute(<<-SQL, fname, lname)
            INSERT INTO 
                users (fname, lname) 
            VALUES 
                (?, ?)
        SQL

        @id = ForumDBConnection.instance.last_insert_row_id
    end

    def update 
        raise "User does not exist" unless id 

        ForumDBConnection.instance.execute(<<-SQL, fname, lname, id)
            UPDATE
                users 
            SET 
                fname = ?, lname = ?
            WHERE 
                id = ? 
        SQL
    end 

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_author_id(self.id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end 

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)
    end 

end